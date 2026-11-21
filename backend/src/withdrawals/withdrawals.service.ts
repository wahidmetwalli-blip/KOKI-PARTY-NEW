import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';

import { DataSource } from 'typeorm';

import {
  HostEarning,
  EarningStatus,
} from '../earnings/earning.entity';

import {
  WithdrawalRequest,
  WithdrawalMethod,
  WithdrawalStatus,
} from './withdrawal.entity';

@Injectable()
export class WithdrawalsService {
  constructor(
    private readonly dataSource: DataSource,
  ) {}

  async createWithdrawal(
    hostUserId: string,
    amount: string,
    method: WithdrawalMethod,
  ) {
    if (!/^[1-9]\d*$/.test(amount)) {
      throw new BadRequestException(
        'Amount must be a positive whole number',
      );
    }

    if (!Object.values(WithdrawalMethod).includes(method)) {
      throw new BadRequestException(
        'Invalid withdrawal method',
      );
    }

    return this.dataSource.transaction(
      async (manager) => {
        const earningsRepository =
          manager.getRepository(HostEarning);

        const withdrawalRepository =
          manager.getRepository(WithdrawalRequest);

        const earnings = await earningsRepository
          .createQueryBuilder('earning')
          .setLock('pessimistic_write')
          .where('earning.hostUserId = :hostUserId', {
            hostUserId,
          })
          .andWhere('earning.status = :status', {
            status: EarningStatus.APPROVED,
          })
          .andWhere(
            'earning.withdrawalRequestId IS NULL',
          )
          .orderBy('earning.createdAt', 'ASC')
          .getMany();

        let total = 0n;

        const selectedEarnings: HostEarning[] = [];

        const requestedAmount = BigInt(amount);

        for (const earning of earnings) {
          const earningAmount = BigInt(earning.amount);

          if (
            total + earningAmount <= requestedAmount
          ) {
            selectedEarnings.push(earning);
            total += earningAmount;
          }

          if (total === requestedAmount) {
            break;
          }
        }

        if (total !== requestedAmount) {
          throw new BadRequestException(
            'Insufficient approved earnings or amount does not match available earning records',
          );
        }

        const withdrawal = withdrawalRepository.create({
          hostUserId,
          amount,
          currency: 'EUR',
          method,
          status: WithdrawalStatus.PENDING,
          assignedAgentId: null,
          paymentReference: null,
          reviewedBy: null,
          reviewNote: null,
          paidAt: null,
        });

        const savedWithdrawal =
          await withdrawalRepository.save(withdrawal);

        for (const earning of selectedEarnings) {
          earning.status =
            EarningStatus.WITHDRAWAL_REQUESTED;

          earning.withdrawalRequestId =
            savedWithdrawal.id;
        }

        await earningsRepository.save(selectedEarnings);

        return savedWithdrawal;
      },
    );
  }

  async getMyWithdrawals(hostUserId: string) {
    return this.dataSource
      .getRepository(WithdrawalRequest)
      .find({
        where: { hostUserId },
        order: { createdAt: 'DESC' },
        take: 100,
      });
  }

  async getWithdrawalById(
    hostUserId: string,
    withdrawalId: string,
  ) {
    const withdrawal = await this.dataSource
      .getRepository(WithdrawalRequest)
      .findOne({
        where: {
          id: withdrawalId,
          hostUserId,
        },
      });

    if (!withdrawal) {
      throw new NotFoundException(
        'Withdrawal request not found',
      );
    }

    return withdrawal;
  }
          }
