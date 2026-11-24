
import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import {
  WeeklyDiamondTaskPeriod,
  WeeklyDiamondTaskReward,
  WeeklyDiamondPeriodStatus,
  WeeklyDiamondRewardStatus,
} from './weekly-diamond-task.entity';

import { HostDiamondLedger } from '../host-diamonds/host-diamond-ledger.entity';

import {
  PoliciesService,
} from '../policies/policies.service';

import {
  PolicyCategory,
} from '../policies/policy.entity';

interface DiamondTaskLevel {
  level: number;
  requiredDiamonds: string;
  rewardCoins: string;
}

@Injectable()
export class WeeklyDiamondTasksService {
  constructor(
    @InjectRepository(WeeklyDiamondTaskPeriod)
    private readonly periodsRepository: Repository<WeeklyDiamondTaskPeriod>,

    @InjectRepository(WeeklyDiamondTaskReward)
    private readonly rewardsRepository: Repository<WeeklyDiamondTaskReward>,

    @InjectRepository(HostDiamondLedger)
    private readonly ledgerRepository: Repository<HostDiamondLedger>,

    private readonly policiesService: PoliciesService,
  ) {}

  private getPreviousWeekRange(now: Date) {
    const riyadhOffset = 3 * 60 * 60 * 1000;

    const riyadhNow = new Date(
      now.getTime() + riyadhOffset,
    );

    const day = riyadhNow.getUTCDay();
    const daysSinceMonday = (day + 6) % 7;

    const mondayLocal = Date.UTC(
      riyadhNow.getUTCFullYear(),
      riyadhNow.getUTCMonth(),
      riyadhNow.getUTCDate() - daysSinceMonday,
      0,
      1,
      0,
      0,
    );

    let periodEnd = new Date(
      mondayLocal - riyadhOffset,
    );

    if (now < periodEnd) {
      periodEnd = new Date(
        periodEnd.getTime() - 7 * 24 * 60 * 60 * 1000,
      );
    }

    const periodStart = new Date(
      periodEnd.getTime() - 7 * 24 * 60 * 60 * 1000,
    );

    return {
      periodStart,
      periodEnd,
    };
  }

  private getTaskLevels(rules: Record<string, any>): DiamondTaskLevel[] {
    if (!Array.isArray(rules.levels) || rules.levels.length === 0) {
      throw new BadRequestException(
        'DIAMOND_TASKS policy must contain a non-empty levels array',
      );
    }

    const levels: DiamondTaskLevel[] = rules.levels.map(
      (item: any) => {
        if (
          !Number.isInteger(item.level) ||
          item.level < 1 ||
          typeof item.requiredDiamonds !== 'string' ||
          !/^[1-9]\d*$/.test(item.requiredDiamonds) ||
          typeof item.rewardCoins !== 'string' ||
          !/^[1-9]\d*$/.test(item.rewardCoins)
        ) {
          throw new BadRequestException(
            'Invalid diamond task level configuration',
          );
        }

        return {
          level: item.level,
          requiredDiamonds: item.requiredDiamonds,
          rewardCoins: item.rewardCoins,
        };
      },
    );

    levels.sort((a, b) => a.level - b.level);

    const seen = new Set<number>();

    for (const level of levels) {
      if (seen.has(level.level)) {
        throw new BadRequestException(
          'Duplicate diamond task level',
        );
      }

      seen.add(level.level);
    }

    return levels;
  }

  async preparePreviousWeekRewards(now = new Date()) {
    const policy = await this.policiesService.getActivePolicy(
      PolicyCategory.DIAMOND_TASKS,
    );

    const levels = this.getTaskLevels(policy.rules);

    const { periodStart, periodEnd } =
      this.getPreviousWeekRange(now);

    let period = await this.periodsRepository.findOne({
      where: { periodStart },
    });

    if (period?.status === WeeklyDiamondPeriodStatus.COMPLETED) {
      return {
        message: 'This weekly period is already completed',
        period,
      };
    }

    if (!period) {
      try {
        period = await this.periodsRepository.save(
          this.periodsRepository.create({
            periodStart,
            periodEnd,
            timezone: 'Asia/Riyadh',
            status: WeeklyDiamondPeriodStatus.OPEN,
            policyVersionId: policy.id,
          }),
        );
      } catch {
        period = await this.periodsRepository.findOne({
          where: { periodStart },
        });

        if (!period) {
          throw new ConflictException(
            'Could not create weekly diamond task period',
          );
        }
      }
    }

    if (period.status === WeeklyDiamondPeriodStatus.PROCESSING) {
      throw new ConflictException(
        'This weekly period is already being processed',
      );
    }

    period.status = WeeklyDiamondPeriodStatus.PROCESSING;
    period.policyVersionId = policy.id;
    period.settlementAttempts += 1;

    await this.periodsRepository.save(period);

    try {
      const totals = await this.ledgerRepository
        .createQueryBuilder('ledger')
        .select('ledger.hostUserId', 'hostUserId')
        .addSelect('SUM(ledger.amount)', 'diamonds')
        .where('ledger.createdAt >= :periodStart', {
          periodStart,
        })
        .andWhere('ledger.createdAt < :periodEnd', {
          periodEnd,
        })
        .groupBy('ledger.hostUserId')
        .getRawMany();

      let totalHosts = 0;

      for (const item of totals) {
        const diamonds = BigInt(String(item.diamonds));

        const eligibleLevels = levels.filter(
          (level) =>
            diamonds >= BigInt(level.requiredDiamonds),
        );

        if (eligibleLevels.length === 0) {
          continue;
        }

        totalHosts++;

        const rewards = eligibleLevels.map((level) => ({
          periodId: period!.id,
          hostUserId: item.hostUserId,
          taskLevel: level.level,
          requiredDiamonds: level.requiredDiamonds,
          diamondsReceived: diamonds.toString(),
          rewardCoins: level.rewardCoins,
          status: WeeklyDiamondRewardStatus.PENDING,
          idempotencyKey:
            `weekly-diamond:${period!.id}:${item.hostUserId}:${level.level}`,
        }));

        await this.rewardsRepository
          .createQueryBuilder()
          .insert()
          .into(WeeklyDiamondTaskReward)
          .values(rewards)
          .orIgnore()
          .execute();
      }

      const summary = await this.rewardsRepository
        .createQueryBuilder('reward')
        .select('COUNT(*)', 'totalRewards')
        .addSelect(
          'COALESCE(SUM(CAST(reward.rewardCoins AS NUMERIC)), 0)',
          'totalCoins',
        )
        .where('reward.periodId = :periodId', {
          periodId: period.id,
        })
        .getRawOne();

      period.totalHosts = totalHosts;
      period.totalRewards = Number(
        summary?.totalRewards ?? 0,
      );
      period.totalCoins = String(
        summary?.totalCoins ?? '0',
      );

      period.status = WeeklyDiamondPeriodStatus.OPEN;

      await this.periodsRepository.save(period);

      return {
        message: 'Weekly diamond rewards prepared successfully',
        period,
      };
    } catch (error) {
      period.status = WeeklyDiamondPeriodStatus.FAILED;
      period.lastError =
        error instanceof Error
          ? error.message.substring(0, 1000)
          : 'Unknown weekly task preparation error';

      await this.periodsRepository.save(period);

      throw error;
    }
  }

  async getPeriodRewards(periodId: string) {
    const period = await this.periodsRepository.findOne({
      where: { id: periodId },
    });

    if (!period) {
      throw new NotFoundException(
        'Weekly diamond task period not found',
      );
    }

    const rewards = await this.rewardsRepository.find({
      where: { periodId },
      order: {
        hostUserId: 'ASC',
        taskLevel: 'ASC',
      },
    });

    return {
      period,
      rewards,
    };
  }

  async getHostRewards(hostUserId: string) {
    return this.rewardsRepository.find({
      where: { hostUserId },
      order: {
        createdAt: 'DESC',
        taskLevel: 'ASC',
      },
      take: 100,
    });
  }
         }
