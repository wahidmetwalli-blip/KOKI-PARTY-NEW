
import {
  Controller,
  Get,
  Req,
  UseGuards,
} from '@nestjs/common';

import { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { HostDiamondsService } from './host-diamonds.service';

interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    role: string;
    permissions: string[];
  };
}

@Controller('host-diamonds')
@UseGuards(JwtAuthGuard)
export class HostDiamondsController {
  constructor(
    private readonly hostDiamondsService: HostDiamondsService,
  ) {}

  @Get('me/history')
  getMyDiamondHistory(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.hostDiamondsService.getHostDiamondHistory(
      req.user.id,
    );
  }

  @Get('me/total')
  getMyDiamondTotal(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.hostDiamondsService.getHostDiamondTotal(
      req.user.id,
    );
  }
}
