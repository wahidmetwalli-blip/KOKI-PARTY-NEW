
import { timingSafeEqual } from 'node:crypto';

import {
  Controller,
  Get,
  Post,
  Param,
  Headers,
  UseGuards,
  ForbiddenException,
  CanActivate,
  ExecutionContext,
  Injectable,
  ParseUUIDPipe,
  UnauthorizedException,
  InternalServerErrorException,
  HttpCode,
} from '@nestjs/common';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';

import {
  WeeklyDiamondTasksService,
} from './weekly-diamond-tasks.service';

import {
  WeeklyDiamondPeriodStatus,
} from './weekly-diamond-task.entity';

@Injectable()
class WeeklyDiamondTasksOwnerGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || user.role !== 'OWNER') {
      throw new ForbiddenException(
        'Only the application owner can manage weekly diamond rewards',
      );
    }

    return true;
  }
}

@Controller('weekly-diamond-tasks')
export class WeeklyDiamondTasksController {
  constructor(
    private readonly weeklyTasksService: WeeklyDiamondTasksService,
  ) {}

  // تجهيز مكافآت الأسبوع السابق - للمالك فقط
  @Post('prepare')
  @UseGuards(JwtAuthGuard, WeeklyDiamondTasksOwnerGuard)
  preparePreviousWeekRewards() {
    return this.weeklyTasksService.preparePreviousWeekRewards();
  }

  // عرض مكافآت فترة محددة - للمالك فقط
  @Get(':periodId/rewards')
  @UseGuards(JwtAuthGuard, WeeklyDiamondTasksOwnerGuard)
  getPeriodRewards(
    @Param('periodId', ParseUUIDPipe) periodId: string,
  ) {
    return this.weeklyTasksService.getPeriodRewards(periodId);
  }

  // صرف مكافآت الفترة - للمالك فقط
  @Post(':periodId/pay')
  @UseGuards(JwtAuthGuard, WeeklyDiamondTasksOwnerGuard)
  payPeriodRewards(
    @Param('periodId', ParseUUIDPipe) periodId: string,
  ) {
    return this.weeklyTasksService.payPeriodRewards(periodId);
  }

  // تشغيل أسبوعي آلي من خدمة خارجية
  // الحماية باستخدام سر مشترك محفوظ في متغيرات البيئة
  @Post('internal/settle-previous-week')
  @HttpCode(200)
  async settlePreviousWeek(
    @Headers('x-koki-cron-secret')
    suppliedSecret?: string,
  ) {
    const configuredSecret =
      process.env.WEEKLY_TASKS_CRON_SECRET;

    if (!configuredSecret || !suppliedSecret) {
      throw new UnauthorizedException(
        'Weekly settlement authentication is not configured',
      );
    }

    const expected = Buffer.from(
      configuredSecret,
      'utf8',
    );

    const supplied = Buffer.from(
      suppliedSecret,
      'utf8',
    );

    if (
      expected.length !== supplied.length ||
      !timingSafeEqual(expected, supplied)
    ) {
      throw new UnauthorizedException(
        'Invalid weekly settlement secret',
      );
    }

    // تجهيز مكافآت الأسبوع السابق
    const preparation =
      await this.weeklyTasksService.preparePreviousWeekRewards();

    const period = preparation?.period;

    if (!period?.id) {
      throw new InternalServerErrorException(
        'Weekly diamond period could not be prepared',
      );
    }

    // منع إعادة صرف أسبوع مكتمل
    if (
      period.status === WeeklyDiamondPeriodStatus.COMPLETED
    ) {
      return {
        success: true,
        alreadyCompleted: true,
        periodId: period.id,
        message: 'This weekly period is already completed',
      };
    }

    // صرف المكافآت المستحقة
    const payment =
      await this.weeklyTasksService.payPeriodRewards(
        period.id,
      );

    return {
      success: payment.remaining === 0,
      alreadyCompleted: false,
      periodId: period.id,
      preparation: preparation.message,
      payment,
    };
  }
}
