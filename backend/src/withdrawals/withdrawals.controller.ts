
import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Req,
  Query,
  UseGuards,
  ParseUUIDPipe,
  BadRequestException,
} from '@nestjs/common';

import { Request } from 'express';

import {
  IsEnum,
  IsString,
  Matches,
  IsOptional,
  IsUUID,
  MaxLength,
} from 'class-validator';

import { WithdrawalsService } from './withdrawals.service';
import {
  WithdrawalMethod,
  WithdrawalStatus,
} from './withdrawal.entity';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PermissionsGuard } from '../auth/permissions.guard';
import { RequirePermissions } from '../auth/permissions.decorator';
import { Permission } from '../auth/permissions.enum';

class CreateWithdrawalDto {
  @IsString()
  @Matches(/^[1-9]\d*$/)
  amount: string;

  @IsEnum(WithdrawalMethod)
  method: WithdrawalMethod;
}

class ReviewWithdrawalDto {
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  note?: string;
}

class RejectWithdrawalDto {
  @IsString()
  @MaxLength(1000)
  note: string;
}

class AssignRechargeAgentDto {
  @IsUUID()
  agentId: string;
}

class MarkWithdrawalPaidDto {
  @IsString()
  @MaxLength(255)
  paymentReference: string;
}

interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    role: string;
    permissions: string[];
  };
}

@Controller('withdrawals')
@UseGuards(JwtAuthGuard)
export class WithdrawalsController {
  constructor(
    private readonly withdrawalsService: WithdrawalsService,
  ) {}

  // Host: create withdrawal request
  @Post()
  createWithdrawal(
    @Req() req: AuthenticatedRequest,
    @Body() dto: CreateWithdrawalDto,
  ) {
    return this.withdrawalsService.createWithdrawal(
      req.user.id,
      dto.amount,
      dto.method,
    );
  }

  // Host: view own withdrawals
  @Get()
  getMyWithdrawals(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.withdrawalsService.getMyWithdrawals(
      req.user.id,
    );
  }

  // Admin: list withdrawal requests
  @Get('admin/all')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.WITHDRAWALS_VIEW)
  adminList(
    @Query('status') status?: string,
  ) {
    if (
      status &&
      !Object.values(WithdrawalStatus).includes(
        status as WithdrawalStatus,
      )
    ) {
      throw new BadRequestException('Invalid withdrawal status');
    }

    return this.withdrawalsService.adminList(
      status as WithdrawalStatus | undefined,
    );
  }

  // Admin: approve request
  @Post('admin/:id/approve')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.WITHDRAWALS_APPROVE)
  approveWithdrawal(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: AuthenticatedRequest,
    @Body() dto: ReviewWithdrawalDto,
  ) {
    return this.withdrawalsService.approveWithdrawal(
      id,
      req.user.id,
      dto.note,
    );
  }

  // Admin: reject request
  @Post('admin/:id/reject')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(Permission.WITHDRAWALS_APPROVE)
  rejectWithdrawal(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: AuthenticatedRequest,
    @Body() dto: RejectWithdrawalDto,
  ) {
    return this.withdrawalsService.rejectWithdrawal(
      id,
      req.user.id,
      dto.note,
    );
  }

  // Admin: assign active recharge agent
  @Post('admin/:id/assign-agent')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(
    Permission.WITHDRAWALS_APPROVE,
    Permission.RECHARGE_MANAGE,
  )
  assignRechargeAgent(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: AuthenticatedRequest,
    @Body() dto: AssignRechargeAgentDto,
  ) {
    return this.withdrawalsService.assignRechargeAgent(
      id,
      dto.agentId,
      req.user.id,
    );
  }

  // Admin: record externally completed payment
  @Post('admin/:id/mark-paid')
  @UseGuards(PermissionsGuard)
  @RequirePermissions(
    Permission.WITHDRAWALS_APPROVE,
    Permission.RECHARGE_MANAGE,
  )
  markWithdrawalPaid(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: AuthenticatedRequest,
    @Body() dto: MarkWithdrawalPaidDto,
  ) {
    return this.withdrawalsService.markWithdrawalPaid(
      id,
      req.user.id,
      dto.paymentReference,
    );
  }

  // Host: view one of own requests
  @Get(':id')
  getMyWithdrawalById(
    @Req() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.withdrawalsService.getWithdrawalById(
      req.user.id,
      id,
    );
  }
  }
  
