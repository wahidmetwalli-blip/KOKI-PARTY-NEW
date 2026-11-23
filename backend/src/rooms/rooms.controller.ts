import {
  Body,
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  ParseUUIDPipe,
  Req,
  UseGuards,
} from '@nestjs/common';

import {
  IsString,
  IsOptional,
  MaxLength,
  IsUrl,
  IsNotEmpty,
} from 'class-validator';

import { RoomsService } from './rooms.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

class CreateRoomDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  @IsUrl({ require_protocol: true })
  coverUrl?: string;
}

class UpdateRoomDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  @IsUrl({ require_protocol: true })
  coverUrl?: string;
}

@Controller('rooms')
export class RoomsController {
  constructor(
    private readonly roomsService: RoomsService,
  ) {}

  @Get()
  findAll() {
    return this.roomsService.findAll();
  }

  @Get(':id')
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.roomsService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  create(
    @Req() req: any,
    @Body() dto: CreateRoomDto,
  ) {
    return this.roomsService.create(
      req.user.id,
      dto,
    );
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
    @Body() dto: UpdateRoomDto,
  ) {
    return this.roomsService.update(
      id,
      req.user.id,
      dto,
    );
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  close(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: any,
  ) {
    return this.roomsService.close(
      id,
      req.user.id,
    );
  }
}
