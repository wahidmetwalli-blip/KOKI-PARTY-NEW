import {
  Body,
  Controller,
  Get,
  Post,
  UseGuards,
} from '@nestjs/common';

import {
  IsEnum,
  IsNumber,
  IsOptional,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

import { AgentsService } from './agents.service';
import { AgentType } from './agent.entity';

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

  @Post('hosts')
  @RequirePermissions(Permission.HOSTS_MANAGE)
  createHost(@Body() dto: CreateAgentDto) {
    return this.agentsService.create(
      dto.userId,
      AgentType.HOST,
      dto.commissionRate ?? 0,
    );
  }

  @Post('recharge')
  @RequirePermissions(Permission.RECHARGE_MANAGE)
  createRechargeAgent(@Body() dto: CreateAgentDto) {
    return this.agentsService.create(
      dto.userId,
      AgentType.RECHARGE,
      dto.commissionRate ?? 0,
    );
  }
      }
