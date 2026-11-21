import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { HostEarning } from './earning.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      HostEarning,
    ]),
  ],
  exports: [
    TypeOrmModule,
  ],
})
export class EarningsModule {}
