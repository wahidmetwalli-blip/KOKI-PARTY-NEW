import {
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';

import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

import { UsersService } from '../users/users.service';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async login(dto: LoginDto) {
    const identifier = dto.identifier.trim();

    const user = identifier.includes('@')
      ? await this.usersService.findByEmail(
          identifier.toLowerCase(),
        )
      : await this.usersService.findByPhone(identifier);

    if (!user || !user.isActive) {
      throw new UnauthorizedException(
        'Invalid login credentials',
      );
    }

    const passwordMatches = await bcrypt.compare(
      dto.password,
      user.passwordHash,
    );

    if (!passwordMatches) {
      throw new UnauthorizedException(
        'Invalid login credentials',
      );
    }

    const accessToken = await this.jwtService.signAsync({
      sub: user.id,
    });

    return {
      access_token: accessToken,
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
    };
  }
}
