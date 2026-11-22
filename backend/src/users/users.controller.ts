import {
  Controller,
  Get,
  UseGuards,
  ForbiddenException,
} from '@nestjs/common';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UsersService } from './users.service';

@Controller('admin/users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
  ) {}

  @Get('count')
  async countUsers() {
    return {
      totalUsers: await this.usersService.countUsers(),
    };
  }
}
