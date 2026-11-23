import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  ParseUUIDPipe,
  ParseIntPipe,
  Body,
  Req,
  UseGuards,
  IsBoolean,
  IsNotEmpty,
} from '@nestjs/common';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RoomSeatsService } from './room-seats.service';

class SeatMuteDto {
  @IsBoolean()
  isMuted: boolean;
}

@Controller('rooms/:roomId/seats')
export class RoomSeatsController {
  constructor(
    private readonly roomSeatsService: RoomSeatsService,
  ) {}

  @Get()
  findAll(
    @Param('roomId', ParseUUIDPipe) roomId: string,
  ) {
    return this.roomSeatsService.findAll(roomId);
  }

  @Post(':seatNumber/take')
  @UseGuards(JwtAuthGuard)
  take(
    @Param('roomId', ParseUUIDPipe) roomId: string,
    @Param('seatNumber', ParseIntPipe) seatNumber: number,
    @Req() req: any,
  ) {
    return this.roomSeatsService.take(
      roomId,
      seatNumber,
      req.user.id,
    );
  }

  @Delete('leave')
  @UseGuards(JwtAuthGuard)
  leave(
    @Param('roomId', ParseUUIDPipe) roomId: string,
    @Req() req: any,
  ) {
    return this.roomSeatsService.leave(
      roomId,
      req.user.id,
    );
  }

  @Patch(':seatNumber/mute')
  @UseGuards(JwtAuthGuard)
  setMute(
    @Param('roomId', ParseUUIDPipe) roomId: string,
    @Param('seatNumber', ParseIntPipe) seatNumber: number,
    @Req() req: any,
    @Body() dto: SeatMuteDto,
  ) {
    return this.roomSeatsService.setMute(
      roomId,
      seatNumber,
      req.user.id,
      dto.isMuted,
    );
  }
}
