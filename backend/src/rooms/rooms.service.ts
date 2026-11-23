
import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Room } from './room.entity';
import { User } from '../users/user.entity';

@Injectable()
export class RoomsService {
  constructor(
    @InjectRepository(Room)
    private readonly roomsRepository: Repository<Room>,

    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async findAll() {
    return this.roomsRepository.find({
      where: { isActive: true },
      order: { createdAt: 'DESC' },
      take: 100,
    });
  }

  async findOne(id: string) {
    const room = await this.roomsRepository.findOne({
      where: { id, isActive: true },
    });

    if (!room) {
      throw new NotFoundException('Room not found');
    }

    return room;
  }

  async create(
    userId: string,
    data: {
      name: string;
      description?: string;
      coverUrl?: string;
    },
  ) {
    const user = await this.usersRepository.findOne({
      where: { id: userId, isActive: true },
    });

    if (!user) {
      throw new NotFoundException('User not found or inactive');
    }

    const name = data.name?.trim();

    if (!name || name.length > 120) {
      throw new BadRequestException('Invalid room name');
    }

    const room = this.roomsRepository.create({
      name,
      description: data.description?.trim() || null,
      coverUrl: data.coverUrl?.trim() || null,
      ownerUserId: userId,
      maxSeats: 8,
      isActive: true,
    });

    return this.roomsRepository.save(room);
  }

  async update(
    id: string,
    userId: string,
    data: {
      name?: string;
      description?: string;
      coverUrl?: string;
    },
  ) {
    const room = await this.roomsRepository.findOne({
      where: { id },
    });

    if (!room) {
      throw new NotFoundException('Room not found');
    }

    if (room.ownerUserId !== userId) {
      throw new ForbiddenException('Room owner only');
    }

    if (data.name !== undefined) {
      const name = data.name.trim();

      if (!name || name.length > 120) {
        throw new BadRequestException('Invalid room name');
      }

      room.name = name;
    }

    if (data.description !== undefined) {
      room.description = data.description.trim() || null;
    }

    if (data.coverUrl !== undefined) {
      room.coverUrl = data.coverUrl.trim() || null;
    }

    return this.roomsRepository.save(room);
  }

  async close(id: string, userId: string) {
    const room = await this.roomsRepository.findOne({
      where: { id },
    });

    if (!room) {
      throw new NotFoundException('Room not found');
    }

    if (room.ownerUserId !== userId) {
      throw new ForbiddenException('Room owner only');
    }

    room.isActive = false;

    return this.roomsRepository.save(room);
  }
        }
