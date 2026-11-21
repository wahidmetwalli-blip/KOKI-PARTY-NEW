import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { PolicyVersion } from './policy.entity';
import { PoliciesService } from './policies.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([PolicyVersion]),
  ],
  providers: [PoliciesService],
  exports: [PoliciesService],
})
export class PoliciesModule {}
