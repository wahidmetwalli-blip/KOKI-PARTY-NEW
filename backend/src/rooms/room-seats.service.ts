import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';

import { Room } from './room.entity';
import { RoomSeat } from './room-seat.entity';
import { User } from '../users/user.entity';

@Injectable()
export class RoomSeatsService {
  constructor(
    @InjectRepository(RoomSeat)
    private readonly seatsRepository: Repository<RoomSeat>,

    @InjectRepository(Room)
    private readonly roomsRepository: Repository<Room>,

    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async findAll(roomId: string) {
    await this.ensureRoom(roomId);

    return this.seatsRepository.find({
      where: { roomId },
      order: { seatNumber: 'ASC' },
    });
  }

  async take(roomId: string, seatNumber: number, userId: string) {
    await this.ensureRoom(roomId);

    if (seatNumber < 1 || seatNumber > 8) {
      throw new BadRequestException('Invalid seat number');
    }

    const user = await this.usersRepository.findOne({
      where: { id: userId, isActive: true },
    });

    if (!user) {
      throw new NotFoundException('User not found or inactive');
    }

    const existingSeat = await this.seatsRepository.findOne({
      where: { roomId, userId },
    });

    if (existingSeat) {
      throw new ConflictException('You are already seated in this room');
    }

    const result = await this.seatsRepository.update(
      { roomId, seatNumber, userId: IsNull() },
      {
        userId,
        isMuted: true,
        occupiedAt: new Date(),
      },
    );

    if (!result.affected) {
      const seat = await this.seatsRepository.findOne({
        where: { roomId, seatNumber },
      });

      if (!seat) {
        throw new NotFoundException('Seat not found');
      }

      throw new ConflictException('Seat is already occupied');
    }

    return this.seatsRepository.findOne({
      where: { roomId, seatNumber },
    });
  }

  async leave(roomId: string, userId: string) {
    await this.ensureRoom(roomId);

    const result = await this.seatsRepository.update(
      { roomId, userId },
      {
        userId: null,
        isMuted: true,
        occupiedAt: null,
      },
    );

    if (!result.affected) {
      throw new NotFoundException('You are not seated in this room');
    }

    return { success: true, message: 'You left the seat' };
  }

  async setMute(
    roomId: string,
    seatNumber: number,
    userId: string,
    isMuted: boolean,
  ) {
    await this.ensureRoom(roomId);

    const result = await this.seatsRepository.update(
      { roomId, seatNumber, userId },
      { isMuted },
    );

    if (!result.affected) {
      throw new NotFoundException('Your seat was not found');
    }

    return this.seatsRepository.findOne({
      where: { roomId, seatNumber },
    });
  }

  private async ensureRoom(roomId: string) {
    const room = await this.roomsRepository.findOne({
      where: { id: roomId, isActive: true },
    });

    if (!room) {
      throw new NotFoundException('Room not found or inactive');
    }
  }
       }
