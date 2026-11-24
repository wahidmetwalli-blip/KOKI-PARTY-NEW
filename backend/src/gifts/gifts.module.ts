
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Gift } from './gift.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Gift]),
  ],
  exports: [
    TypeOrmModule,
  ],
})
export class GiftsModule {}
