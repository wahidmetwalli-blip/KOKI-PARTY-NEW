
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import {
  WeeklyDiamondTaskPeriod,
  WeeklyDiamondTaskReward,
} from './weekly-diamond-task.entity';

import { HostDiamondLedger } from '../host-diamonds/host-diamond-ledger.entity';
import { HostDiamondsModule } from '../host-diamonds/host-diamonds.module';
import { WalletModule } from '../wallet/wallet.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      WeeklyDiamondTaskPeriod,
      WeeklyDiamondTaskReward,
      HostDiamondLedger,
    ]),
    HostDiamondsModule,
    WalletModule,
  ],
  providers: [],
  controllers: [],
  exports: [TypeOrmModule],
})
export class WeeklyDiamondTasksModule {}
