import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import {
  Wallet,
  WalletTransaction,
} from './wallet.entity';

import { WalletService } from './wallet.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Wallet,
      WalletTransaction,
    ]),
  ],
  providers: [WalletService],
  exports: [WalletService],
})
export class WalletModule {}
