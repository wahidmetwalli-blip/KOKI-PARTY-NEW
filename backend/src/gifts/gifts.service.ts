
import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Gift } from './gift.entity';

export interface CreateGiftData {
  name: string;
  nameEn?: string;
  description?: string;
  imageUrl?: string;
  emoji?: string;
  coinPrice: string;
  sortOrder?: number;
}

@Injectable()
export class GiftsService {
  constructor(
    @InjectRepository(Gift)
    private readonly giftsRepository: Repository<Gift>,
  ) {}

  async getActiveGifts(): Promise<Gift[]> {
    return this.giftsRepository.find({
      where: { isActive: true },
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

  async createGift(data: CreateGiftData): Promise<Gift> {
    this.validateGiftData(data);

    const gift = this.giftsRepository.create({
      name: data.name.trim(),
      nameEn: data.nameEn?.trim() || null,
      description: data.description?.trim() || null,
      imageUrl: data.imageUrl?.trim() || null,
      emoji: data.emoji?.trim() || null,
      coinPrice: data.coinPrice,
      sortOrder: data.sortOrder ?? 0,
      isActive: true,
    });

    return this.giftsRepository.save(gift);
  }

  async updateGift(
    giftId: string,
    data: Partial<CreateGiftData> & {
      isActive?: boolean;
    },
  ): Promise<Gift> {
    const gift = await this.giftsRepository.findOne({
      where: { id: giftId },
    });

    if (!gift) {
      throw new NotFoundException('Gift not found');
    }

    if (data.name !== undefined) {
      if (!data.name.trim()) {
        throw new BadRequestException(
          'Gift name cannot be empty',
        );
      }
      gift.name = data.name.trim();
    }

    if (data.nameEn !== undefined) {
      gift.nameEn = data.nameEn?.trim() || null;
    }

    if (data.description !== undefined) {
      gift.description = data.description?.trim() || null;
    }

    if (data.imageUrl !== undefined) {
      gift.imageUrl = data.imageUrl?.trim() || null;
    }

    if (data.emoji !== undefined) {
      gift.emoji = data.emoji?.trim() || null;
    }

    if (data.coinPrice !== undefined) {
      this.validatePrice(data.coinPrice);
      gift.coinPrice = data.coinPrice;
    }

    if (data.sortOrder !== undefined) {
      this.validateSortOrder(data.sortOrder);
      gift.sortOrder = data.sortOrder;
    }

    if (data.isActive !== undefined) {
      gift.isActive = data.isActive;
    }

    return this.giftsRepository.save(gift);
  }

  private validateGiftData(data: CreateGiftData): void {
    if (!data.name || !data.name.trim()) {
      throw new BadRequestException(
        'Gift name is required',
      );
    }

    this.validatePrice(data.coinPrice);

    if (data.sortOrder !== undefined) {
      this.validateSortOrder(data.sortOrder);
    }
  }

  private validatePrice(price: string): void {
    if (
      typeof price !== 'string' ||
      !/^[1-9]\d*$/.test(price)
    ) {
      throw new BadRequestException(
        'Gift coin price must be a positive integer',
      );
    }
  }

  private validateSortOrder(sortOrder: number): void {
    if (
      !Number.isInteger(sortOrder) ||
      sortOrder < 0
    ) {
      throw new BadRequestException(
        'Sort order must be a non-negative integer',
      );
    }
  }
}
