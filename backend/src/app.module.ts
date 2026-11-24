
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { DatabaseModule } from './database/database.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { RoomsModule } from './rooms/rooms.module';
import { AgentsModule } from './agents/agents.module';
import { WalletModule } from './wallet/wallet.module';
import { EarningsModule } from './earnings/earnings.module';
import { WithdrawalsModule } from './withdrawals/withdrawals.module';
import { PoliciesModule } from './policies/policies.module';
import { AuditModule } from './audit/audit.module';
import { HostDiamondsModule } from './host-diamonds/host-diamonds.module';
import { WeeklyDiamondTasksModule } from './weekly-diamond-tasks/weekly-diamond-tasks.module';
import { GiftsModule } from './gifts/gifts.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    DatabaseModule,
    AuthModule,
    UsersModule,
    RoomsModule,
    AgentsModule,
    WalletModule,
    EarningsModule,
    HostDiamondsModule,
    WithdrawalsModule,
    PoliciesModule,
    AuditModule,
    WeeklyDiamondTasksModule,
    GiftsModule,
  ],
})
export class AppModule {}
