import {
  Body,
  Controller,
  Get,
  Post,
  Patch,
  Param,
  ParseUUIDPipe,
  UseGuards,
  Req,
} from '@nestjs/common';

import {
  IsEnum,
  IsNumber,
  IsOptional,
  IsUUID,
  IsString,
  IsNotEmpty,
  Max,
  Min,
  MaxLength,
  Matches,
} from 'class-validator';

import { AgentsService } from './agents.service';
import { AgentType, AgentStatus } from './agent.entity';
import { AgentPayoutStatus } from './agent-payout.entity';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PermissionsGuard } from '../auth/permissions.guard';
import { RequirePermissions } from '../auth/permissions.decorator';
import { Permission } from '../auth/permissions.enum';

class CreateAgentDto {
  @IsUUID()
  userId: string;

  @IsEnum(AgentType)
  type: AgentType;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  commissionRate?: number;
}

class UpdateStatusDto {
  @IsEnum(AgentStatus)
  status: AgentStatus;
}

class UpdateCommissionDto {
  @IsNumber()
  @Min(0)
  @Max(100)
  commissionRate: number;
}

class RequestAgentPayoutDto {
  @IsString()
  @Matches(/^[1-9]\d*$/)
  amount: string;
}

class ReviewAgentPayoutDto {
  @IsEnum(AgentPayoutStatus)
  status: AgentPayoutStatus;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  note?: string;
}

class MarkAgentPayoutPaidDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  paymentReference: string;
}

@Controller('agents')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class AgentsController {
  constructor(
    private readonly agentsService: AgentsService,
  ) {}

  @Get()
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  findAll() {
    return this.agentsService.findAll();
  }

  @Get('statistics')
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  getStatistics() {
    return this.agentsService.getStatistics();
  }

  @Get('commissions/statistics')
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  getCommissionStatistics() {
    return this.agentsService.getCommissionStatistics();
  }

  @Get(':id/commissions')
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  getAgentCommissions(
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.agentsService.getAgentCommissions(id);
  }

  @Get(':id/financial-summary')
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  getAgentFinancialSummary(
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.agentsService.getAgentFinancialSummary(id);
  }

  @Get(':id/payouts')
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  getAgentPayouts(
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.agentsService.getAgentPayouts(id);
  }

  @Post(':id/payouts')
  @RequirePermissions(Permission.RECHARGE_MANAGE)
  requestAgentPayout(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RequestAgentPayoutDto,
  ) {
    return this.agentsService.requestAgentPayout(
      id,
      dto.amount,
    );
  }

  @Patch('payouts/:payoutId/review')
  @RequirePermissions(Permission.RECHARGE_MANAGE)
  reviewAgentPayout(
    @Req() req: any,
    @Param('payoutId', ParseUUIDPipe) payoutId: string,
    @Body() dto: ReviewAgentPayoutDto,
  ) {
    return this.agentsService.reviewAgentPayout(
      payoutId,
      dto.status as
        | AgentPayoutStatus.APPROVED
        | AgentPayoutStatus.REJECTED,
      req.user.id,
      dto.note,
    );
  }

  @Patch('payouts/:payoutId/paid')
  @RequirePermissions(Permission.RECHARGE_MANAGE)
  markAgentPayoutPaid(
    @Req() req: any,
    @Param('payoutId', ParseUUIDPipe) payoutId: string,
    @Body() dto: MarkAgentPayoutPaidDto,
  ) {
    return this.agentsService.markAgentPayoutPaid(
      payoutId,
      dto.paymentReference,
      req.user.id,
    );
  }

  @Post('hosts')
  @RequirePermissions(Permission.HOSTS_MANAGE)
  createHost(
    @Req() req: any,
    @Body() dto: CreateAgentDto,
  ) {
    return this.agentsService.create(
      dto.userId,
      AgentType.HOST,
      dto.commissionRate ?? 0,
      req.user.id,
    );
  }

  @Post('recharge')
  @RequirePermissions(Permission.RECHARGE_MANAGE)
  createRechargeAgent(
    @Req() req: any,
    @Body() dto: CreateAgentDto,
  ) {
    return this.agentsService.create(
      dto.userId,
      AgentType.RECHARGE,
      dto.commissionRate ?? 0,
      req.user.id,
    );
  }

  @Patch(':id/status')
  @RequirePermissions(Permission.STAFF_MANAGE)
  updateStatus(
    @Req() req: any,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateStatusDto,
  ) {
    return this.agentsService.updateStatus(
      id,
      dto.status,
      req.user.id,
    );
  }

  @Patch(':id/commission')
  @RequirePermissions(Permission.STAFF_MANAGE)
  updateCommission(
    @Req() req: any,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCommissionDto,
  ) {
    return this.agentsService.updateCommission(
      id,
      dto.commissionRate,
      req.user.id,
    );
  }
           }
