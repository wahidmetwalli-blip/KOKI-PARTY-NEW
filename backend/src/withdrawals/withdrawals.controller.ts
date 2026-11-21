
import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Req,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';

import { Request } from 'express';

import {
  IsEnum,
  IsString,
  Matches,
} from 'class-validator';

import { WithdrawalsService } from './withdrawals.service';
import { WithdrawalMethod } from './withdrawal.entity';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

class CreateWithdrawalDto {
  @IsString()
  @Matches(/^[1-9]\d*$/)
  amount: string;

  @IsEnum(WithdrawalMethod)
  method: WithdrawalMethod;
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

  @Post()
  createWithdrawal(
    @Req() req: AuthenticatedRequest,
    @Body() dto: CreateWithdrawalDto,
  ) {
    // Amount is always submitted in USD cents.
    // 1000 cents = 10 USD.
    // Currency is fixed to USD by the backend service.
    return this.withdrawalsService.createWithdrawal(
      req.user.id,
      dto.amount,
      dto.method,
    );
  }

  @Get()
  getMyWithdrawals(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.withdrawalsService.getMyWithdrawals(
      req.user.id,
    );
  }

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
