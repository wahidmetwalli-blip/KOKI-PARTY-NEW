import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { PolicyVersion } from './policy.entity';
import { PoliciesController } from './policies.controller';
import { PoliciesService } from './policies.service';

import { HostLevel } from './host-level.entity';
import { HostLevelService } from './host-level.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PolicyVersion,
      HostLevel,
    ]),
  ],
  controllers: [
    PoliciesController,
  ],
  providers: [
    PoliciesService,
    HostLevelService,
  ],
  exports: [
    PoliciesService,
    HostLevelService,
  ],
})
export class PoliciesModule {}
