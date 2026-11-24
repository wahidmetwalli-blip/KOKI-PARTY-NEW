
import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Gift } from './gift.entity';

@Injectable()
export class GiftsService {
  constructor(
    @InjectRepository(Gift)
    private readonly giftsRepository: Repository<Gift>,
  ) {}

  async getActiveGifts(): Promise<Gift[]> {
    return this.giftsRepository.find({
      where: {
        isActive: true,
      },
      order: {
        sortOrder: 'ASC',
        createdAt: 'ASC',
      },
    });
  }

  async getAllGifts(): Promise<Gift[]> {
    return this.giftsRepository.find({
      order: {
        sortOrder: 'ASC',
        createdAt: 'ASC',
      },
    });
  }

  async getGiftById(giftId: string): Promise<Gift> {
    const gift = await this.giftsRepository.findOne({
      where: {
        id: giftId,
        isActive: true,
      },
    });

    if (!gift) {
      throw new NotFoundException(
        'Gift not found or inactive',
      );
    }

    return gift;
  }
}
