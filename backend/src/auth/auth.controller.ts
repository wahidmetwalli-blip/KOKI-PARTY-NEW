import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
} from '@nestjs/common';

import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
  ) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('setup-owner')
  @HttpCode(HttpStatus.CREATED)
  async setupOwner(
    @Body()
    dto: {
      email?: string;
      phone?: string;
      password: string;
      setupKey: string;
    },
  ) {
    return this.authService.setupOwner(dto);
  }
}
