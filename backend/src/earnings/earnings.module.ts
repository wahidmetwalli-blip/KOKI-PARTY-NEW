import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { HostEarning } from './earning.entity';
import { EarningsService } from './earnings.service';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      HostEarning,
    ]),
    UsersModule,
  ],
  providers: [
    EarningsService,
  ],
  exports: [
    EarningsService,
  ],
})
export class EarningsModule {}
