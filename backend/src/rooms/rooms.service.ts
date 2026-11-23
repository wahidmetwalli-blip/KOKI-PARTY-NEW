
import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import {
  Repository,
  IsNull,
  MoreThan,
} from 'typeorm';

import { Room } from './room.entity';
import { RoomSeat } from './room-seat.entity';
import { User } from '../users/user.entity';

@Injectable()
export class RoomsService {
  constructor(
    @InjectRepository(Room)
    private readonly roomsRepository: Repository<Room>,

    @InjectRepository(RoomSeat)
    private readonly roomSeatsRepository: Repository<RoomSeat>,

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

    const savedRoom = await this.roomsRepository.save(room);

    const seats = Array.from({ length: 8 }, (_, index) =>
      this.roomSeatsRepository.create({
        roomId: savedRoom.id,
        seatNumber: index + 1,
        userId: null,
        isMuted: true,
        occupiedAt: null,
      }),
    );

    await this.roomSeatsRepository.save(seats);

    return {
      ...savedRoom,
      seats,
    };
  }

  async update(
    id: string,
    userId: string,
    data: {
      name?: string;
      description?: string;
      coverUrl?: string;
      maxSeats?: number;
    },
  ) {
    return this.roomsRepository.manager.transaction(
      async (manager) => {
        const roomsRepository = manager.getRepository(Room);
        const seatsRepository = manager.getRepository(RoomSeat);

        const room = await roomsRepository.findOne({
          where: { id },
          lock: { mode: 'pessimistic_write' },
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

        if (data.maxSeats !== undefined) {
          const allowedSeatCounts = [10, 12, 15, 20];

          if (!allowedSeatCounts.includes(data.maxSeats)) {
            throw new BadRequestException(
              'Seat count must be 10, 12, 15 or 20',
            );
          }

          const occupiedSeatsAboveLimit = await seatsRepository.count({
            where: {
              roomId: id,
              seatNumber: MoreThan(data.maxSeats),
              userId: null,
            },
          });

          const occupiedSeats = await seatsRepository
            .createQueryBuilder('seat')
            .where('seat.roomId = :roomId', { roomId: id })
            .andWhere('seat.seatNumber > :maxSeats', {
              maxSeats: data.maxSeats,
            })
            .andWhere('seat.userId IS NOT NULL')
            .getCount();

          if (occupiedSeats > 0) {
            throw new ConflictException(
              'Cannot reduce seats while higher-numbered seats are occupied',
            );
          }

          room.maxSeats = data.maxSeats;

          await seatsRepository.delete({
            roomId: id,
            seatNumber: MoreThan(data.maxSeats),
            userId: IsNull(),
          });

          const existingSeats = await seatsRepository.find({
            where: { roomId: id },
            select: ['seatNumber'],
          });

          const existingNumbers = new Set(
            existingSeats.map((seat) => seat.seatNumber),
          );

          const missingSeats: RoomSeat[] = [];

          for (let number = 1; number <= data.maxSeats; number++) {
            if (!existingNumbers.has(number)) {
              missingSeats.push(
                seatsRepository.create({
                  roomId: id,
                  seatNumber: number,
                  userId: null,
                  isMuted: true,
                  occupiedAt: null,
                }),
              );
            }
          }

          if (missingSeats.length > 0) {
            await seatsRepository.save(missingSeats);
          }
        }

        const savedRoom = await roomsRepository.save(room);

        const seats = await seatsRepository.find({
          where: { roomId: id },
          order: { seatNumber: 'ASC' },
        });

        return {
          ...savedRoom,
          seats,
        };
      },
    );
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
              
