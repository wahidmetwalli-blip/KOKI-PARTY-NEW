
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
  NotFoundException,
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
import {
  Agent,
  AgentType,
  AgentStatus,
} from './agent.entity';
import { AgentPayoutStatus } from './agent-payout.entity';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PermissionsGuard } from '../auth/permissions.guard';
import { RequirePermissions } from '../auth/permissions.decorator';
import { Permission } from '../auth/permissions.enum';

class CreateAgentDto {
  @IsUUID()
  userId: string;

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

interface AuthenticatedRequest {
  user: {
    id: string;
    role: string;
    permissions: string[];
  };
}

@Controller('agents')
@UseGuards(JwtAuthGuard)
export class AgentsController {
  constructor(
    private readonly agentsService: AgentsService,
  ) {}

  private async getMyRechargeAgent(
    req: AuthenticatedRequest,
  ): Promise<Agent> {
    const agents = await this.agentsService.findByUser(
      req.user.id,
      AgentType.RECHARGE,
    );

    const agent = agents.find(
      item => item.status === AgentStatus.ACTIVE,
    );

    if (!agent) {
      throw new NotFoundException(
        'Active recharge agent account not found',
      );
    }

    return agent;
  }

  // Recharge agent: own financial summary
  @Get('me/financial-summary')
  getMyFinancialSummary(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.getMyRechargeAgent(req).then(agent =>
      this.agentsService.getAgentFinancialSummary(agent.id),
    );
  }

  // Recharge agent: own commissions
  @Get('me/commissions')
  getMyCommissions(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.getMyRechargeAgent(req).then(agent =>
      this.agentsService.getAgentCommissions(agent.id),
    );
  }

  // Recharge agent: own payout history
  @Get('me/payouts')
  getMyPayouts(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.getMyRechargeAgent(req).then(agent =>
      this.agentsService.getAgentPayouts(agent.id),
    );
  }

  // Recharge agent: request payout from own balance only
  @Post('me/payouts')
  requestMyPayout(
    @Req() req: AuthenticatedRequest,
    @Body() dto: RequestAgentPayoutDto,
  ) {
    return this.getMyRechargeAgent(req).then(agent =>
      this.agentsService.requestAgentPayout(
        agent.id,
        dto.amount,
      ),
    );
  }

  // Admin: list agents
  @Get()
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  findAll() {
    return this.agentsService.findAll();
  }

  @Get('statistics')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  getStatistics() {
    return this.agentsService.getStatistics();
  }

  @Get('commissions/statistics')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  getCommissionStatistics() {
    return this.agentsService.getCommissionStatistics();
  }

  @Get(':id/commissions')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  getAgentCommissions(
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.agentsService.getAgentCommissions(id);
  }

  @Get(':id/financial-summary')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  getAgentFinancialSummary(
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.agentsService.getAgentFinancialSummary(id);
  }

  @Get(':id/payouts')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.DASHBOARD_VIEW)
  getAgentPayouts(
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.agentsService.getAgentPayouts(id);
  }

  // Admin: review agent payout
  @Patch('payouts/:payoutId/review')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.RECHARGE_MANAGE)
  reviewAgentPayout(
    @Req() req: AuthenticatedRequest,
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

  // Admin: record agent payout payment
  @Patch('payouts/:payoutId/paid')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.RECHARGE_MANAGE)
  markAgentPayoutPaid(
    @Req() req: AuthenticatedRequest,
    @Param('payoutId', ParseUUIDPipe) payoutId: string,
    @Body() dto: MarkAgentPayoutPaidDto,
  ) {
    return this.agentsService.markAgentPayoutPaid(
      payoutId,
      dto.paymentReference,
      req.user.id,
    );
  }

  // Admin: create host agent
  @Post('hosts')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.HOSTS_MANAGE)
  createHost(
    @Req() req: AuthenticatedRequest,
    @Body() dto: CreateAgentDto,
  ) {
    return this.agentsService.create(
      dto.userId,
      AgentType.HOST,
      dto.commissionRate ?? 0,
      req.user.id,
    );
  }

  // Admin: create recharge agent
  @Post('recharge')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.RECHARGE_MANAGE)
  createRechargeAgent(
    @Req() req: AuthenticatedRequest,
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
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.STAFF_MANAGE)
  updateStatus(
    @Req() req: AuthenticatedRequest,
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
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.STAFF_MANAGE)
  updateCommission(
    @Req() req: AuthenticatedRequest,
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
