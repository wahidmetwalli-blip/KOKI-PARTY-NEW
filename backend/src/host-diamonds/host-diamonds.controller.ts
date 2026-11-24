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
import {
  IsString,
  IsNotEmpty,
  Matches,
  MaxLength,
  IsOptional,
} from 'class-validator';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { HostDiamondsService } from './host-diamonds.service';

interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    role: string;
    permissions: string[];
  };
}

class SendGiftDto {
  @IsString()
  @IsNotEmpty()
  hostUserId: string;

  @IsString()
  @Matches(/^[1-9]\d*$/)
  giftCoinAmount: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  reference: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;
}

@Controller('host-diamonds')
@UseGuards(JwtAuthGuard)
export class HostDiamondsController {
  constructor(
    private readonly hostDiamondsService: HostDiamondsService,
  ) {}

  @Post('send-gift')
  sendGift(
    @Req() req: AuthenticatedRequest,
    @Body() dto: SendGiftDto,
  ) {
    if (!req.user?.id) {
      throw new BadRequestException('Unauthenticated sender');
    }

    return this.hostDiamondsService.sendGift(
      req.user.id,
      dto.hostUserId,
      dto.giftCoinAmount,
      dto.reference,
      dto.description,
    );
  }

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
