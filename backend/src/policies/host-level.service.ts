
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
    const level = data.level;

    if (
      level === undefined ||
      !Number.isInteger(level) ||
      level < 1 ||
      level > 12
    ) {
      throw new BadRequestException('Level must be between 1 and 12');
    }

    if (
      data.requiredDiamonds === undefined ||
      !/^\d+$/.test(String(data.requiredDiamonds))
    ) {
      throw new BadRequestException('Invalid required diamonds value');
    }

    if (
      data.hostSalaryUsdCents === undefined ||
      !/^\d+$/.test(String(data.hostSalaryUsdCents))
    ) {
      throw new BadRequestException('Invalid USD salary cents value');
    }

    const diamondRate = Number(data.diamondRate ?? '100');

    if (
      !Number.isFinite(diamondRate) ||
      diamondRate < 0 ||
      diamondRate > 100
    ) {
      throw new BadRequestException(
        'Diamond rate must be between 0 and 100',
      );
    }

    const existing = await this.hostLevelRepository.findOne({
      where: { level },
    });

    if (existing) {
      throw new BadRequestException('This host level already exists');
    }

    const hostLevel = this.hostLevelRepository.create({
      ...data,
      level,
      diamondRate: diamondRate.toFixed(2),
      salaryCurrency: 'USD',
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

    if (data.hostSalaryUsdCents !== undefined) {
      if (!/^\d+$/.test(String(data.hostSalaryUsdCents))) {
        throw new BadRequestException('Invalid USD salary cents value');
      }
    }

    if (data.diamondRate !== undefined) {
      const rate = Number(data.diamondRate);

      if (
        !Number.isFinite(rate) ||
        rate < 0 ||
        rate > 100
      ) {
        throw new BadRequestException(
          'Diamond rate must be between 0 and 100',
        );
      }

      hostLevel.diamondRate = rate.toFixed(2);
    }

    if (data.level !== undefined) {
      if (
        !Number.isInteger(data.level) ||
        data.level < 1 ||
        data.level > 12
      ) {
        throw new BadRequestException('Level must be between 1 and 12');
      }

      if (data.level !== level) {
        const existing = await this.hostLevelRepository.findOne({
          where: { level: data.level },
        });

        if (existing) {
          throw new BadRequestException('This host level already exists');
        }
      }

      hostLevel.level = data.level;
    }

    if (data.requiredDiamonds !== undefined) {
      hostLevel.requiredDiamonds = data.requiredDiamonds;
    }

    if (data.hostSalaryUsdCents !== undefined) {
      hostLevel.hostSalaryUsdCents = data.hostSalaryUsdCents;
    }

    if (data.vipLevel !== undefined) {
      hostLevel.vipLevel = data.vipLevel;
    }

    if (data.systemDisplay !== undefined) {
      hostLevel.systemDisplay = data.systemDisplay;
    }

    if (data.isActive !== undefined) {
      hostLevel.isActive = data.isActive;
    }

    hostLevel.salaryCurrency = 'USD';

    return this.hostLevelRepository.save(hostLevel);
  }

  async deactivateLevel(level: number): Promise<HostLevel> {
    const hostLevel = await this.getLevelByNumber(level);

    hostLevel.isActive = false;

    return this.hostLevelRepository.save(hostLevel);
  }
      }
