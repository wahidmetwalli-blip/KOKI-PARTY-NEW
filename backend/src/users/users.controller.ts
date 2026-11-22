
import {
  Controller,
  Get,
  UseGuards,
  ForbiddenException,
  Req,
} from '@nestjs/common';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UsersService } from './users.service';

@Controller('admin/users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
  ) {}

  @Get()
  async getUsers(@Req() req: any) {
    if (req.user?.role !== 'OWNER') {
      throw new ForbiddenException('Owner access required');
    }

    return {
      users: await this.usersService.findUsersForAdmin(),
    };
  }

  @Get('count')
  async countUsers(@Req() req: any) {
    if (req.user?.role !== 'OWNER') {
      throw new ForbiddenException('Owner access required');
    }

    return {
      totalUsers: await this.usersService.countUsers(),
    };
  }
}
