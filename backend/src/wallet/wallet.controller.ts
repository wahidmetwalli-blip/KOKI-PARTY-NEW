import {
  Controller,
  Get,
  Post,
  Body,
  Req,
  UseGuards,
  BadRequestException,
} from '@nestjs/common';
import { Request } from 'express';
import { IsInt, IsPositive, IsString, MaxLength } from 'class-validator';

import { WalletService } from './wallet.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AgentsService } from '../agents/agents.service';
import { AgentType, AgentStatus } from '../agents/agent.entity';
import { WalletTransactionType } from './wallet.entity';

interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    role: string;
    permissions: string[];
  };
}

class RechargeWalletDto {
  @IsString()
  userId: string;

  @IsInt()
  @IsPositive()
  amount: number;

  @IsString()
  @MaxLength(150)
  idempotencyKey: string;
}

@Controller('wallet')
@UseGuards(JwtAuthGuard)
export class WalletController {
  constructor(
    private readonly walletService: WalletService,
    private readonly agentsService: AgentsService,
  ) {}

  @Get()
  getMyWallet(@Req() req: AuthenticatedRequest) {
    return this.walletService.getWallet(req.user.id);
  }

  @Get('transactions')
  getMyTransactions(@Req() req: AuthenticatedRequest) {
    return this.walletService.getTransactions(req.user.id);
  }

  @Post('recharge')
  async rechargeUser(
    @Req() req: AuthenticatedRequest,
    @Body() dto: RechargeWalletDto,
  ) {
    if (!dto.userId || dto.userId === req.user.id) {
      throw new BadRequestException('Invalid target user');
    }

    const agent = await this.agentsService.findByUser(
      req.user.id,
      AgentType.RECHARGE,
    );

    if (!agent || agent.status !== AgentStatus.ACTIVE) {
      throw new BadRequestException(
        'Active recharge agent account required',
      );
    }

    return this.walletService.adjustBalance(
      dto.userId,
      WalletTransactionType.CREDIT,
      String(dto.amount),
      'Recharge by recharge agent',
      dto.idempotencyKey,
      `agent:${agent.id}`,
    );
  }
    }
