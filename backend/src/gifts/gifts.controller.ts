
import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  UseGuards,
  ParseUUIDPipe,
  ForbiddenException,
  CanActivate,
  ExecutionContext,
  Injectable,
} from '@nestjs/common';

import {
  IsString,
  IsOptional,
  IsBoolean,
  IsInt,
  Min,
  MaxLength,
  Matches,
} from 'class-validator';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GiftsService } from './gifts.service';

@Injectable()
class GiftOwnerGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || user.role !== 'OWNER') {
      throw new ForbiddenException(
        'Only the application owner can manage gifts',
      );
    }

    return true;
  }
}

class CreateGiftDto {
  @IsString()
  @MaxLength(100)
  name: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  nameEn?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  imageUrl?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  emoji?: string;

  @IsString()
  @Matches(/^[1-9]\d*$/)
  coinPrice: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;
}

class UpdateGiftDto {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  nameEn?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  imageUrl?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  emoji?: string;

  @IsOptional()
  @IsString()
  @Matches(/^[1-9]\d*$/)
  coinPrice?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

@Controller('gifts')
export class GiftsController {
  constructor(
    private readonly giftsService: GiftsService,
  ) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  getActiveGifts() {
    return this.giftsService.getActiveGifts().then((gifts) => ({
      success: true,
      count: gifts.length,
      data: gifts,
    }));
  }

  @Get('admin/all')
  @UseGuards(JwtAuthGuard, GiftOwnerGuard)
  getAllGifts() {
    return this.giftsService.getAllGifts();
  }

  @Post('admin')
  @UseGuards(JwtAuthGuard, GiftOwnerGuard)
  createGift(@Body() dto: CreateGiftDto) {
    return this.giftsService.createGift(dto);
  }

  @Patch('admin/:id')
  @UseGuards(JwtAuthGuard, GiftOwnerGuard)
  updateGift(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateGiftDto,
  ) {
    return this.giftsService.updateGift(id, dto);
  }
}
