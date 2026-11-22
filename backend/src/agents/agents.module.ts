
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Agent } from './agent.entity';
import { AgentCommission } from './agent-commission.entity';
import { AgentsService } from './agents.service';
import { AgentsController } from './agents.controller';

import { AuthModule } from '../auth/auth.module';
import { AuditModule } from '../audit/audit.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Agent,
      AgentCommission,
    ]),
    AuthModule,
    AuditModule,
  ],
  controllers: [AgentsController],
  providers: [AgentsService],
  exports: [AgentsService],
})
export class AgentsModule {}
