import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';

import { JwtStrategy } from './jwt.strategy';
import { PermissionsGuard } from './permissions.guard';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { AuthProfileController } from './auth-profile.controller';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    UsersModule,

    PassportModule.register({
      defaultStrategy: 'jwt',
    }),

    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.getOrThrow<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: '15m',
        },
      }),
    }),
  ],

  controllers: [AuthController, AuthProfileController],

  providers: [
    JwtStrategy,
    PermissionsGuard,
    AuthService,
  ],

  exports: [
    JwtModule,
    PassportModule,
    PermissionsGuard,
    AuthService,
  ],
})
export class AuthModule {}
