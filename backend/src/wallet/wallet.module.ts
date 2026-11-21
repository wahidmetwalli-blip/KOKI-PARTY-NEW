import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import {
  Wallet,
  WalletTransaction,
} from './wallet.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Wallet,
      WalletTransaction,
    ]),
  ],
  exports: [
    TypeOrmModule,
  ],
})
export class WalletModule {}
