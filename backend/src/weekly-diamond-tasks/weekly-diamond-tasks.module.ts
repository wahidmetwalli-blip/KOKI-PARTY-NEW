
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import {
  WeeklyDiamondTaskPeriod,
  WeeklyDiamondTaskReward,
} from './weekly-diamond-task.entity';

import { HostDiamondLedger } from '../host-diamonds/host-diamond-ledger.entity';
import { HostDiamondsModule } from '../host-diamonds/host-diamonds.module';
import { WalletModule } from '../wallet/wallet.module';
import { PoliciesModule } from '../policies/policies.module';

import { WeeklyDiamondTasksService } from './weekly-diamond-tasks.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      WeeklyDiamondTaskPeriod,
      WeeklyDiamondTaskReward,
      HostDiamondLedger,
    ]),
    HostDiamondsModule,
    WalletModule,
    PoliciesModule,
  ],
  providers: [
    WeeklyDiamondTasksService,
  ],
  controllers: [],
  exports: [
    WeeklyDiamondTasksService,
  ],
})
export class WeeklyDiamondTasksModule {}
