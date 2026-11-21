import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { QueryFailedError, Repository } from 'typeorm';

import {
  HostEarning,
  EarningSource,
  EarningStatus,
} from './earning.entity';

import { UsersService } from '../users/users.service';

@Injectable()
export class EarningsService {
  constructor(
    @InjectRepository(HostEarning)
    private readonly earningsRepository: Repository<HostEarning>,

    private readonly usersService: UsersService,
  ) {}

  async createEarning(
    hostUserId: string,
    source: EarningSource,
    amount: string,
    reference: string,
    description?: string,
  ) {
    if (!/^[1-9]\d*$/.test(amount)) {
      throw new BadRequestException(
        'Amount must be a positive whole number',
      );
    }

    if (
      !reference ||
      reference.trim().length === 0 ||
      reference.length > 150
    ) {
      throw new BadRequestException(
        'A valid unique reference is required',
      );
    }

    const host = await this.usersService.findById(hostUserId);

    if (!host || !host.isActive) {
      throw new NotFoundException(
        'Active host account not found',
      );
    }

    const existing = await this.earningsRepository.findOne({
      where: { reference },
    });

    if (existing) {
      throw new ConflictException(
        'This earning has already been recorded',
      );
    }

    const earning = this.earningsRepository.create({
      hostUserId,
      source,
      status: EarningStatus.PENDING,
      amount,
      reference,
      description: description || null,
    });

    try {
      return await this.earningsRepository.save(earning);
    } catch (error) {
      if (
        error instanceof QueryFailedError &&
        (error as any).driverError?.code === '23505'
      ) {
        throw new ConflictException(
          'This earning reference already exists',
        );
      }

      throw error;
    }
  }

  async getHostEarnings(hostUserId: string) {
    return this.earningsRepository.find({
      where: { hostUserId },
      order: { createdAt: 'DESC' },
      take: 100,
    });
  }

  async getHostEarningsSummary(hostUserId: string) {
    const earnings = await this.earningsRepository.find({
      where: { hostUserId },
    });

    const summary = {
      pending: 0n,
      approved: 0n,
      paid: 0n,
      cancelled: 0n,
    };

    for (const earning of earnings) {
      const amount = BigInt(earning.amount);

      switch (earning.status) {
        case EarningStatus.PENDING:
          summary.pending += amount;
          break;

        case EarningStatus.APPROVED:
          summary.approved += amount;
          break;

        case EarningStatus.PAID:
          summary.paid += amount;
          break;

        case EarningStatus.CANCELLED:
          summary.cancelled += amount;
          break;
      }
    }

    return {
      pending: summary.pending.toString(),
      approved: summary.approved.toString(),
      paid: summary.paid.toString(),
      cancelled: summary.cancelled.toString(),
    };
  }
    }
