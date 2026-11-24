
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
  MaxLength,
  IsOptional,
  IsInt,
  Min,
  Max,
  IsUUID,
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
  @IsUUID()
  hostUserId: string;

  @IsUUID()
  roomId: string;

  @IsInt()
  @Min(1)
  @Max(20)
  seatNumber: number;

  @IsUUID()
  giftId: string;

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
      throw new BadRequestException(
        'Unauthenticated sender',
      );
    }

    return this.hostDiamondsService.sendGift(
      req.user.id,
      dto.hostUserId,
      dto.giftId,
      dto.reference,
      dto.roomId,
      dto.seatNumber,
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
