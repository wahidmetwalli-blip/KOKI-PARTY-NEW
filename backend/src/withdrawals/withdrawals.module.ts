import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { WithdrawalRequest } from './withdrawal.entity';
import { HostEarning } from '../earnings/earning.entity';
import { WithdrawalsService } from './withdrawals.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      WithdrawalRequest,
      HostEarning,
    ]),
  ],
  providers: [WithdrawalsService],
  exports: [WithdrawalsService],
})
export class WithdrawalsModule {}
