
import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { WithdrawalRequest } from './withdrawal.entity';
import { HostEarning } from '../earnings/earning.entity';

@Injectable()
export class WithdrawalsService {
  constructor(
    @InjectRepository(WithdrawalRequest)
    private readonly withdrawalsRepository: Repository<WithdrawalRequest>,
    @InjectRepository(HostEarning)
    private readonly earningsRepository: Repository<HostEarning>,
    private readonly dataSource: DataSource,
  ) {}

  async createWithdrawal(userId: string, amount: number) {
    if (!Number.isSafeInteger(amount) || amount <= 0) {
      throw new BadRequestException('Invalid withdrawal amount');
    }

    return this.dataSource.transaction(async (manager) => {
      const earnings = await manager
        .getRepository(HostEarning)
        .createQueryBuilder('earning')
        .setLock('pessimistic_write')
        .where('earning.userId = :userId', { userId })
        .andWhere('earning.status = :status', { status: 'APPROVED' })
        .orderBy('earning.createdAt', 'ASC')
        .getMany();

      let remaining = amount;
      const selected: HostEarning[] = [];

      for (const earning of earnings) {
        const available = Number(earning.amount);

        if (!Number.isSafeInteger(available) || available <= 0) {
          continue;
        }

        if (available <= remaining) {
          selected.push(earning);
          remaining -= available;
        }

        if (remaining === 0) break;
      }

      if (remaining !== 0) {
        throw new BadRequestException(
          'Insufficient approved earnings for this withdrawal',
        );
      }

      const withdrawal = manager
        .getRepository(WithdrawalRequest)
        .create({
          userId,
          amount,
          currency: 'USD',
          status: 'PENDING',
        });

      const savedWithdrawal = await manager
        .getRepository(WithdrawalRequest)
        .save(withdrawal);

      for (const earning of selected) {
        earning.status = 'WITHDRAWAL_REQUESTED';
        earning.withdrawalRequestId = savedWithdrawal.id;
      }

      await manager.getRepository(HostEarning).save(selected);

      return savedWithdrawal;
    });
  }

  async findMyWithdrawals(userId: string) {
    return this.withdrawalsRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async findMyWithdrawalById(userId: string, id: string) {
    const withdrawal = await this.withdrawalsRepository.findOne({
      where: { id, userId },
    });

    if (!withdrawal) {
      throw new NotFoundException('Withdrawal request not found');
    }

    return withdrawal;
  }
                             }
    
