import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { WithdrawalRequest } from './withdrawal.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      WithdrawalRequest,
    ]),
  ],
  exports: [
    TypeOrmModule,
  ],
})
export class WithdrawalsModule {}
