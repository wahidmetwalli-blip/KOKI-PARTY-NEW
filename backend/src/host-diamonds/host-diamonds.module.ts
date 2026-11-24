
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { HostDiamondLedger } from './host-diamond-ledger.entity';
import { HostDiamondsService } from './host-diamonds.service';
import { HostDiamondsController } from './host-diamonds.controller';

import { UsersModule } from '../users/users.module';
import { PoliciesModule } from '../policies/policies.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      HostDiamondLedger,
    ]),
    UsersModule,
    PoliciesModule,
  ],
  controllers: [
    HostDiamondsController,
  ],
  providers: [
    HostDiamondsService,
  ],
  exports: [
    HostDiamondsService,
  ],
})
export class HostDiamondsModule {}
