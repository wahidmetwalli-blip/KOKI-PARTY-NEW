
import {
  Controller,
  Get,
  Post,
  Body,
  Req,
  UseGuards,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { Request } from 'express';
import {
  IsInt,
  IsPositive,
  IsString,
  MaxLength,
} from 'class-validator';

import { WalletService } from './wallet.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AgentsService } from '../agents/agents.service';
import { AgentType, AgentStatus } from '../agents/agent.entity';

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
  @MaxLength(146)
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

    const agents = await this.agentsService.findByUser(
      req.user.id,
      AgentType.RECHARGE,
    );

    const agent = agents.find(
      (item) => item.status === AgentStatus.ACTIVE,
    );

    if (!agent) {
      throw new ForbiddenException(
        'Active recharge agent account required',
      );
    }

    return this.walletService.rechargeFromAgent(
      agent.id,
      req.user.id,
      dto.userId,
      String(dto.amount),
      dto.idempotencyKey,
    );
  }
}
