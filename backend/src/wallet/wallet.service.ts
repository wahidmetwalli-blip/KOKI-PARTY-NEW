
import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
  ForbiddenException,
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

import {
  Agent,
  AgentType,
  AgentStatus,
} from '../agents/agent.entity';

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

    if (existing) return existing;

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

    return this.dataSource.transaction(async (manager) => {
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

      const transaction = transactionRepository.create({
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
    });
  }

  async rechargeFromAgent(
    agentId: string,
    agentUserId: string,
    targetUserId: string,
    amount: string,
    idempotencyKey: string,
  ) {
    if (
      !/^[1-9]\d*$/.test(amount) ||
      !idempotencyKey ||
      idempotencyKey.length > 146
    ) {
      throw new BadRequestException('Invalid recharge data');
    }

    if (
      !agentUserId ||
      !targetUserId ||
      agentUserId === targetUserId
    ) {
      throw new BadRequestException('Invalid recharge users');
    }

    return this.dataSource.transaction(async (manager) => {
      const agentsRepo = manager.getRepository(Agent);
      const walletsRepo = manager.getRepository(Wallet);
      const transactionsRepo =
        manager.getRepository(WalletTransaction);

      const agent = await agentsRepo
        .createQueryBuilder('agent')
        .setLock('pessimistic_write')
        .where('agent.id = :agentId', { agentId })
        .andWhere('agent.userId = :agentUserId', { agentUserId })
        .getOne();

      if (
        !agent ||
        agent.type !== AgentType.RECHARGE ||
        agent.status !== AgentStatus.ACTIVE
      ) {
        throw new ForbiddenException(
          'Active recharge agent required',
        );
      }

      const debitKey = `${idempotencyKey}:OUT`;
      const creditKey = `${idempotencyKey}:IN`;

      const previousDebit = await transactionsRepo.findOne({
        where: { idempotencyKey: debitKey },
      });

      const previousCredit = await transactionsRepo.findOne({
        where: { idempotencyKey: creditKey },
      });

      if (previousDebit && previousCredit) {
        if (
          previousDebit.amount !== amount ||
          previousCredit.amount !== amount
        ) {
          throw new ConflictException(
            'Idempotency key already used',
          );
        }

        return previousCredit;
      }

      if (previousDebit || previousCredit) {
        throw new ConflictException(
          'Incomplete previous recharge transaction',
        );
      }

      const userIds = [agentUserId, targetUserId].sort();

      const lockedWallets = new Map<string, Wallet>();

      for (const userId of userIds) {
        const wallet = await walletsRepo
          .createQueryBuilder('wallet')
          .setLock('pessimistic_write')
          .where('wallet.userId = :userId', { userId })
          .getOne();

        if (!wallet) {
          throw new NotFoundException(
            `Wallet not found for user ${userId}`,
          );
        }

        lockedWallets.set(userId, wallet);
      }

      const agentWallet = lockedWallets.get(agentUserId)!;
      const targetWallet = lockedWallets.get(targetUserId)!;

      const value = BigInt(amount);
      const agentBefore = BigInt(agentWallet.coinBalance);
      const targetBefore = BigInt(targetWallet.coinBalance);

      if (agentBefore < value) {
        throw new BadRequestException(
          'Insufficient agent coin balance',
        );
      }

      const agentAfter = agentBefore - value;
      const targetAfter = targetBefore + value;

      agentWallet.coinBalance = agentAfter.toString();
      targetWallet.coinBalance = targetAfter.toString();

      agent.totalRecharged = (
        BigInt(agent.totalRecharged) + value
      ).toString();

      await walletsRepo.save([
        agentWallet,
        targetWallet,
      ]);

      await agentsRepo.save(agent);

      const debit = transactionsRepo.create({
        walletId: agentWallet.id,
        type: WalletTransactionType.DEBIT,
        amount,
        balanceBefore: agentBefore.toString(),
        balanceAfter: agentAfter.toString(),
        description: 'Recharge transfer to user',
        reference: `agent:${agent.id}`,
        idempotencyKey: debitKey,
      });

      const credit = transactionsRepo.create({
        walletId: targetWallet.id,
        type: WalletTransactionType.CREDIT,
        amount,
        balanceBefore: targetBefore.toString(),
        balanceAfter: targetAfter.toString(),
        description: 'Recharge received from agent',
        reference: `agent:${agent.id}`,
        idempotencyKey: creditKey,
      });

      await transactionsRepo.save([debit, credit]);

      return credit;
    });
  }
    }
                                       
