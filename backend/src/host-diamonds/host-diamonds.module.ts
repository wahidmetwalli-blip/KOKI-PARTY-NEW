
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { HostDiamondLedger } from './host-diamond-ledger.entity';
import { HostDiamondsService } from './host-diamonds.service';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([HostDiamondLedger]),
    UsersModule,
  ],
  providers: [HostDiamondsService],
  exports: [HostDiamondsService],
})
export class HostDiamondsModule {}
