
import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import {
  QueryFailedError,
  Repository,
} from 'typeorm';

import { HostDiamondLedger } from './host-diamond-ledger.entity';
import { UsersService } from '../users/users.service';

@Injectable()
export class HostDiamondsService {
  constructor(
    @InjectRepository(HostDiamondLedger)
    private readonly ledgerRepository: Repository<HostDiamondLedger>,

    private readonly usersService: UsersService,
  ) {}

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
      reference.length > 150
    ) {
      throw new BadRequestException(
        'Valid host ID and unique reference are required',
      );
    }

    if (
      typeof source !== 'string' ||
      !source.trim() ||
      source.length > 50
    ) {
      throw new BadRequestException('Invalid source');
    }

    const host = await this.usersService.findById(hostUserId);

    if (!host || !host.isActive) {
      throw new NotFoundException(
        'Active host account not found',
      );
    }

    const existing = await this.ledgerRepository.findOne({
      where: { reference: reference.trim() },
    });

    if (existing) {
      throw new ConflictException(
        'This diamond transaction was already recorded',
      );
    }

    const record = this.ledgerRepository.create({
      hostUserId,
      amount,
      reference: reference.trim(),
      source: source.trim(),
      description: description?.trim() || null,
    });

    try {
      return await this.ledgerRepository.save(record);
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
    return this.ledgerRepository.find({
      where: { hostUserId },
      order: { createdAt: 'DESC' },
      take: 100,
    });
  }

  async getHostDiamondTotal(hostUserId: string) {
    const result = await this.ledgerRepository
      .createQueryBuilder('ledger')
      .select('COALESCE(SUM(ledger.amount), 0)', 'total')
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
