
import {
  Controller,
  Get,
  UseGuards,
} from '@nestjs/common';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GiftsService } from './gifts.service';

@Controller('gifts')
@UseGuards(JwtAuthGuard)
export class GiftsController {
  constructor(
    private readonly giftsService: GiftsService,
  ) {}

  @Get()
  async getActiveGifts() {
    const gifts = await this.giftsService.getActiveGifts();

    return {
      success: true,
      count: gifts.length,
      data: gifts,
    };
  }
}
