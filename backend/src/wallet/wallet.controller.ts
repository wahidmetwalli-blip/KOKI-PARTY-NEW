import {
  Controller,
  Get,
  Req,
  UseGuards,
} from '@nestjs/common';
import { Request } from 'express';

import { WalletService } from './wallet.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    role: string;
    permissions: string[];
  };
}

@Controller('wallet')
@UseGuards(JwtAuthGuard)
export class WalletController {
  constructor(
    private readonly walletService: WalletService,
  ) {}

  @Get()
  getMyWallet(@Req() req: AuthenticatedRequest) {
    return this.walletService.getWallet(
      req.user.id,
    );
  }

  @Get('transactions')
  getMyTransactions(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.walletService.getTransactions(
      req.user.id,
    );
  }
}
