import {
  Controller,
  Get,
  Req,
  UseGuards,
} from '@nestjs/common';

import { Request } from 'express';
import { EarningsService } from './earnings.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    role: string;
    permissions: string[];
  };
}

@Controller('earnings')
@UseGuards(JwtAuthGuard)
export class EarningsController {
  constructor(
    private readonly earningsService: EarningsService,
  ) {}

  @Get()
  getMyEarnings(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.earningsService.getHostEarnings(
      req.user.id,
    );
  }

  @Get('summary')
  getMyEarningsSummary(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.earningsService.getHostEarningsSummary(
      req.user.id,
    );
  }
}
