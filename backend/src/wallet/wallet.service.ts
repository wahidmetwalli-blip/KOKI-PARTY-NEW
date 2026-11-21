import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import {
  DataSource,
  Repository,
} from 'typeorm';

import {
  Wallet,
  WalletTransaction,
  WalletTransactionType,
} from './wallet.entity';

@Injectable()
export class WalletService {
  constructor(
    private readonly dataSource: DataSource,

    @InjectRepository(Wallet)
    private readonly walletsRepository: Repository<Wallet>,
  ) {}

  async createWallet(userId: string) {
    if (!userId) {
      throw new BadRequestException('User ID is required');
    }

    const existing = await this.walletsRepository.findOne({
      where: { userId },
    });

    if (existing) {
      return existing;
    }

    const wallet = this.walletsRepository.create({
      userId,
      coinBalance: '0',
    });

    try {
      return await this.walletsRepository.save(wallet);
    } catch {
      const created = await this.walletsRepository.findOne({
        where: { userId },
      });

      if (created) return created;

      throw new ConflictException('Could not create wallet');
    }
  }

  async getWallet(userId: string) {
    const wallet = await this.walletsRepository.findOne({
      where: { userId },
    });

    if (!wallet) {
      throw new NotFoundException('Wallet not found');
    }

    return wallet;
  }

  async getTransactions(userId: string) {
    const wallet = await this.getWallet(userId);

    return this.dataSource
      .getRepository(WalletTransaction)
      .find({
        where: { walletId: wallet.id },
        order: { createdAt: 'DESC' },
        take: 100,
      });
  }

  async adjustBalance(
    userId: string,
    type: WalletTransactionType,
    amount: string,
    description: string,
    idempotencyKey: string,
    reference?: string,
  ) {
    if (!/^[1-9]\d*$/.test(amount)) {
      throw new BadRequestException(
        'Amount must be a positive whole number',
      );
    }

    if (!idempotencyKey || idempotencyKey.length > 150) {
      throw new BadRequestException(
        'A valid idempotency key is required',
      );
    }

    return this.dataSource.transaction(
      async (manager) => {
        const transactionRepository =
          manager.getRepository(WalletTransaction);

        const previous = await transactionRepository.findOne({
          where: { idempotencyKey },
        });

        if (previous) {
          if (
            previous.type !== type ||
            previous.amount !== amount
          ) {
            throw new ConflictException(
              'Idempotency key was already used for another operation',
            );
          }

          return previous;
        }

        const wallet = await manager
          .getRepository(Wallet)
          .createQueryBuilder('wallet')
          .setLock('pessimistic_write')
          .where('wallet.userId = :userId', { userId })
          .getOne();

        if (!wallet) {
          throw new NotFoundException('Wallet not found');
        }

        const before = BigInt(wallet.coinBalance);
        const value = BigInt(amount);

        const after =
          type === WalletTransactionType.CREDIT
            ? before + value
            : before - value;

        if (after < 0n) {
          throw new BadRequestException(
            'Insufficient coin balance',
          );
        }

        wallet.coinBalance = after.toString();

        await manager.getRepository(Wallet).save(wallet);

        const transaction =
          transactionRepository.create({
            walletId: wallet.id,
            type,
            amount,
            balanceBefore: before.toString(),
            balanceAfter: after.toString(),
            description: description || null,
            reference: reference || null,
            idempotencyKey,
          });

        return transactionRepository.save(transaction);
      },
    );
  }
}
