import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HostLevel } from './host-level.entity';

@Injectable()
export class HostLevelService {
  constructor(
    @InjectRepository(HostLevel)
    private readonly hostLevelRepository: Repository<HostLevel>,
  ) {}

  async getAllLevels(): Promise<HostLevel[]> {
    return this.hostLevelRepository.find({
      order: { level: 'ASC' },
    });
  }

  async getActiveLevels(): Promise<HostLevel[]> {
    return this.hostLevelRepository.find({
      where: { isActive: true },
      order: { level: 'ASC' },
    });
  }

  async getLevelByNumber(level: number): Promise<HostLevel> {
    const hostLevel = await this.hostLevelRepository.findOne({
      where: { level },
    });

    if (!hostLevel) {
      throw new NotFoundException('Host level not found');
    }

    return hostLevel;
  }

  async createLevel(data: Partial<HostLevel>): Promise<HostLevel> {
    if (!Number.isInteger(data.level) || data.level < 1 || data.level > 12) {
      throw new BadRequestException('Level must be between 1 and 12');
    }

    if (
      !data.requiredDiamonds ||
      !/^\d+$/.test(String(data.requiredDiamonds))
    ) {
      throw new BadRequestException('Invalid required diamonds value');
    }

    if (
      !data.hostSalaryEurCents ||
      !/^\d+$/.test(String(data.hostSalaryEurCents))
    ) {
      throw new BadRequestException('Invalid salary cents value');
    }

    const existing = await this.hostLevelRepository.findOne({
      where: { level: data.level },
    });

    if (existing) {
      throw new BadRequestException('This host level already exists');
    }

    const hostLevel = this.hostLevelRepository.create({
      ...data,
      diamondRate: data.diamondRate ?? '100.00',
      vipLevel: data.vipLevel ?? 0,
      systemDisplay: data.systemDisplay ?? true,
      isActive: data.isActive ?? true,
    });

    return this.hostLevelRepository.save(hostLevel);
  }

  async updateLevel(
    level: number,
    data: Partial<HostLevel>,
  ): Promise<HostLevel> {
    const hostLevel = await this.getLevelByNumber(level);

    if (data.requiredDiamonds !== undefined) {
      if (!/^\d+$/.test(String(data.requiredDiamonds))) {
        throw new BadRequestException('Invalid required diamonds value');
      }
    }

    if (data.hostSalaryEurCents !== undefined) {
      if (!/^\d+$/.test(String(data.hostSalaryEurCents))) {
        throw new BadRequestException('Invalid salary cents value');
      }
    }

    if (
      data.diamondRate !== undefined &&
      (!Number.isFinite(Number(data.diamondRate)) ||
        Number(data.diamondRate) < 0 ||
        Number(data.diamondRate) > 100)
    ) {
      throw new BadRequestException('Diamond rate must be between 0 and 100');
    }

    if (
      data.level !== undefined &&
      (!Number.isInteger(data.level) || data.level < 1 || data.level > 12)
    ) {
      throw new BadRequestException('Level must be between 1 and 12');
    }

    Object.assign(hostLevel, data);

    return this.hostLevelRepository.save(hostLevel);
  }

  async deactivateLevel(level: number): Promise<HostLevel> {
    const hostLevel = await this.getLevelByNumber(level);

    hostLevel.isActive = false;

    return this.hostLevelRepository.save(hostLevel);
  }
  }
