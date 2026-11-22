import {
  Injectable,
  UnauthorizedException,
  ConflictException,
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

  async setupOwner(dto: {
    email?: string;
    phone?: string;
    password: string;
    setupKey: string;
  }) {
    const expectedKey = process.env.OWNER_SETUP_KEY;

    if (!expectedKey || dto.setupKey !== expectedKey) {
      throw new UnauthorizedException('Invalid setup key');
    }

    if (await this.usersService.countOwners() > 0) {
      throw new ConflictException('Owner already exists');
    }

    const email = dto.email?.trim().toLowerCase() || null;
    const phone = dto.phone?.trim() || null;

    if ((!email && !phone) || dto.password.length < 8) {
      throw new ConflictException('Email or phone and password are required');
    }

    const passwordHash = await bcrypt.hash(dto.password, 12);

    const user = await this.usersService.createOwner(
      email,
      phone,
      passwordHash,
    );

    return {
      message: 'Owner created successfully',
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
    };
  }

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
