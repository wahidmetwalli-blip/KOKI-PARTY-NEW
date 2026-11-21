import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { DatabaseModule } from './database/database.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { AgentsModule } from './agents/agents.module';
import { WalletModule } from './wallet/wallet.module';
import { EarningsModule } from './earnings/earnings.module';
import { WithdrawalsModule } from './withdrawals/withdrawals.module';
import { PoliciesModule } from './policies/policies.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    DatabaseModule,
    AuthModule,
    UsersModule,
    AgentsModule,
    WalletModule,
    EarningsModule,
    WithdrawalsModule,
    PoliciesModule,
  ],
})
export class AppModule {}
