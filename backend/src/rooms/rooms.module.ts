import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Room } from './room.entity';
import { RoomSeat } from './room-seat.entity';
import { User } from '../users/user.entity';

import { RoomsController } from './rooms.controller';
import { RoomSeatsController } from './room-seats.controller';

import { RoomsService } from './rooms.service';
import { RoomSeatsService } from './room-seats.service';

import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Room, RoomSeat, User]),
    AuthModule,
  ],
  controllers: [
    RoomsController,
    RoomSeatsController,
  ],
  providers: [
    RoomsService,
    RoomSeatsService,
  ],
  exports: [
    RoomsService,
    RoomSeatsService,
  ],
})
export class RoomsModule {}
