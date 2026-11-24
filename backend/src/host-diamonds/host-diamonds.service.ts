
import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';

import { DataSource, QueryFailedError } from 'typeorm';

import { HostDiamondLedger } from './host-diamond-ledger.entity';
import { UsersService } from '../users/users.service';

import {
  Wallet,
  WalletTransaction,
  WalletTransactionType,
} from '../wallet/wallet.entity';

import { PoliciesService } from '../policies/policies.service';
import { PolicyCategory } from '../policies/policy.entity';

@Injectable()
export class HostDiamondsService {
  constructor(
    private readonly dataSource: DataSource,
    private readonly usersService: UsersService,
    private readonly policiesService: PoliciesService,
  ) {}

  async getGiftDiamondConversion() {
    const policy = await this.policiesService.getActivePolicy(
      PolicyCategory.COMMISSIONS,
    );

    const rate = String(
      policy.rules?.giftDiamondConversion?.diamondsPerCoin ?? '',
    );

    if (!/^[1-9]\d*$/.test(rate)) {
      throw new BadRequestException(
        'Gift diamond conversion is not configured correctly',
      );
    }

    return {
      policyId: policy.id,
      policyVersion: policy.version,
      diamondsPerCoin: rate,
    };
  }

  async sendGift(
    senderUserId: string,
    hostUserId: string,
    giftCoinAmount: string,
    reference: string,
    description?: string,
  ) {
    if (
      !senderUserId ||
      !hostUserId ||
      senderUserId === hostUserId
    ) {
      throw new BadRequestException(
        'Invalid sender or host account',
      );
    }

    if (
      typeof giftCoinAmount !== 'string' ||
      !/^[1-9]\d*$/.test(giftCoinAmount)
    ) {
      throw new BadRequestException(
        'Gift coin amount must be a positive integer',
      );
    }

    if (
      typeof reference !== 'string' ||
      !reference.trim() ||
      reference.trim().length > 120
    ) {
      throw new BadRequestException(
        'A valid unique gift reference is required',
      );
    }

    const normalizedReference = reference.trim();

    const sender = await this.usersService.findById(senderUserId);
    const host = await this.usersService.findById(hostUserId);

    if (!sender || !sender.isActive) {
      throw new NotFoundException('Active sender not found');
    }

    if (!host || !host.isActive) {
      throw new NotFoundException('Active host not found');
    }

    const conversion = await this.getGiftDiamondConversion();

    const coinAmount = BigInt(giftCoinAmount);
    const diamondsPerCoin = BigInt(
      conversion.diamondsPerCoin,
    );

    const diamondAmount = (
      coinAmount * diamondsPerCoin
    ).toString();

    const debitKey = `gift:${normalizedReference}:debit`;

    try {
      return await this.dataSource.transaction(async (manager) => {
        const walletRepository = manager.getRepository(Wallet);
        const transactionRepository =
          manager.getRepository(WalletTransaction);
        const ledgerRepository =
          manager.getRepository(HostDiamondLedger);

        const existingLedger = await ledgerRepository.findOne({
          where: { reference: normalizedReference },
        });

        const existingTransaction =
          await transactionRepository.findOne({
            where: { idempotencyKey: debitKey },
          });

        if (existingLedger && existingTransaction) {
          if (
            existingLedger.hostUserId !== hostUserId ||
            existingLedger.amount !== diamondAmount ||
            existingTransaction.amount !== giftCoinAmount ||
            existingTransaction.type !== WalletTransactionType.DEBIT
          ) {
            throw new ConflictException(
              'Gift reference was already used with different data',
            );
          }

          return {
            alreadyProcessed: true,
            walletTransaction: existingTransaction,
            diamondRecord: existingLedger,
            coinsDebited: existingTransaction.amount,
            diamondsEarned: existingLedger.amount,
          };
        }

        if (existingLedger || existingTransaction) {
          throw new ConflictException(
            'Incomplete previous gift transaction',
          );
        }

        const wallet = await walletRepository
          .createQueryBuilder('wallet')
          .setLock('pessimistic_write')
          .where('wallet.userId = :userId', {
            userId: senderUserId,
          })
          .getOne();

        if (!wallet) {
          throw new NotFoundException('Sender wallet not found');
        }

        const balanceBefore = BigInt(wallet.coinBalance);

        if (balanceBefore < coinAmount) {
          throw new BadRequestException(
            'Insufficient coin balance',
          );
        }

        const balanceAfter = balanceBefore - coinAmount;

        wallet.coinBalance = balanceAfter.toString();
        await walletRepository.save(wallet);

        const walletTransaction =
          transactionRepository.create({
            walletId: wallet.id,
            type: WalletTransactionType.DEBIT,
            amount: giftCoinAmount,
            balanceBefore: balanceBefore.toString(),
            balanceAfter: balanceAfter.toString(),
            reference: `gift:${normalizedReference}`,
            idempotencyKey: debitKey,
            description:
              description?.trim() ||
              `Gift sent to host ${hostUserId}`,
          });

        const savedTransaction =
          await transactionRepository.save(walletTransaction);

        const diamondRecord = ledgerRepository.create({
          hostUserId,
          amount: diamondAmount,
          source: 'GIFT',
          reference: normalizedReference,
          description:
            `Gift ${giftCoinAmount} coins; ` +
            `${conversion.diamondsPerCoin} diamonds per coin; ` +
            `policy version ${conversion.policyVersion}`,
        });

        const savedDiamondRecord =
          await ledgerRepository.save(diamondRecord);

        return {
          alreadyProcessed: false,
          walletTransaction: savedTransaction,
          diamondRecord: savedDiamondRecord,
          coinsDebited: giftCoinAmount,
          diamondsEarned: diamondAmount,
          conversion: {
            diamondsPerCoin: conversion.diamondsPerCoin,
            policyVersion: conversion.policyVersion,
          },
        };
      });
    } catch (error) {
      if (
        error instanceof QueryFailedError &&
        (error as any).driverError?.code === '23505'
      ) {
        throw new ConflictException(
          'This gift was already processed',
        );
      }

      throw error;
    }
  }

  async recordReceivedDiamonds(
    hostUserId: string,
    amount: string,
    reference: string,
    source = 'GIFT',
    description?: string,
  ) {
    if (
      typeof amount !== 'string' ||
      !/^[1-9]\d*$/.test(amount)
    ) {
      throw new BadRequestException(
        'Diamond amount must be a positive integer',
      );
    }

    if (
      !hostUserId ||
      typeof reference !== 'string' ||
      !reference.trim() ||
      reference.trim().length > 150
    ) {
      throw new BadRequestException(
        'Valid host ID and unique reference are required',
      );
    }

    if (
      typeof source !== 'string' ||
      !source.trim() ||
      source.trim().length > 50
    ) {
      throw new BadRequestException('Invalid source');
    }

    const host = await this.usersService.findById(hostUserId);

    if (!host || !host.isActive) {
      throw new NotFoundException(
        'Active host account not found',
      );
    }

    const repository = this.dataSource.getRepository(
      HostDiamondLedger,
    );

    const normalizedReference = reference.trim();

    const existing = await repository.findOne({
      where: { reference: normalizedReference },
    });

    if (existing) {
      throw new ConflictException(
        'This diamond transaction was already recorded',
      );
    }

    const record = repository.create({
      hostUserId,
      amount,
      reference: normalizedReference,
      source: source.trim(),
      description: description?.trim() || null,
    });

    try {
      return await repository.save(record);
    } catch (error) {
      if (
        error instanceof QueryFailedError &&
        (error as any).driverError?.code === '23505'
      ) {
        throw new ConflictException(
          'This diamond transaction was already recorded',
        );
      }

      throw error;
    }
  }

  async getHostDiamondHistory(hostUserId: string) {
    return this.dataSource
      .getRepository(HostDiamondLedger)
      .find({
        where: { hostUserId },
        order: { createdAt: 'DESC' },
        take: 100,
      });
  }

  async getHostDiamondTotal(hostUserId: string) {
    const result = await this.dataSource
      .getRepository(HostDiamondLedger)
      .createQueryBuilder('ledger')
      .select(
        'COALESCE(SUM(ledger.amount), 0)',
        'total',
      )
      .where('ledger.hostUserId = :hostUserId', {
        hostUserId,
      })
      .getRawOne();

    return {
      hostUserId,
      totalDiamonds: String(result?.total ?? '0'),
    };
  }
      }
                                               
