import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { WithdrawalRequest } from './withdrawal.entity';
import { HostEarning } from '../earnings/earning.entity';
import { Agent } from '../agents/agent.entity';

import { WithdrawalsService } from './withdrawals.service';
import { WithdrawalsController } from './withdrawals.controller';

import { AuthModule } from '../auth/auth.module';
import { AuditModule } from '../audit/audit.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      WithdrawalRequest,
      HostEarning,
      Agent,
    ]),
    AuthModule,
    AuditModule,
  ],
  controllers: [WithdrawalsController],
  providers: [WithdrawalsService],
  exports: [WithdrawalsService],
})
export class WithdrawalsModule {}
