
import {
  Controller,
  Get,
  Post,
  Param,
  UseGuards,
  ForbiddenException,
  CanActivate,
  ExecutionContext,
  Injectable,
  ParseUUIDPipe,
} from '@nestjs/common';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';

import {
  WeeklyDiamondTasksService,
} from './weekly-diamond-tasks.service';

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
@UseGuards(JwtAuthGuard, WeeklyDiamondTasksOwnerGuard)
export class WeeklyDiamondTasksController {
  constructor(
    private readonly weeklyTasksService: WeeklyDiamondTasksService,
  ) {}

  @Post('prepare')
  preparePreviousWeekRewards() {
    return this.weeklyTasksService.preparePreviousWeekRewards();
  }

  @Get(':periodId/rewards')
  getPeriodRewards(
    @Param('periodId', ParseUUIDPipe) periodId: string,
  ) {
    return this.weeklyTasksService.getPeriodRewards(periodId);
  }

  @Post(':periodId/pay')
  payPeriodRewards(
    @Param('periodId', ParseUUIDPipe) periodId: string,
  ) {
    return this.weeklyTasksService.payPeriodRewards(periodId);
  }
}
