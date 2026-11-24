
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { CreateCorePlatformTables1763855900000 } from './migrations/1763855900000-CreateCorePlatformTables';
import { AddUsdCurrencyFields1763856000000 } from './migrations/1763856000000-AddUsdCurrencyFields';
import { CreateAgentCommissions1763857000000 } from './migrations/1763857000000-CreateAgentCommissions';
import { CreateAuditLogs1763857100000 } from './migrations/1763857100000-CreateAuditLogs';
import { CreateRooms1763857200000 } from './migrations/1763857200000-CreateRooms';
import { CreateRoomSeats1763857300000 } from './migrations/1763857300000-CreateRoomSeats';
import { ExpandRoomSeatLimit1763930000000 } from './migrations/1763930000000-ExpandRoomSeatLimit';
import { SeedHostLevels1764000000000 } from './migrations/1764000000000-SeedHostLevels';
import { CreateHostDiamondLedger1764100000000 } from './migrations/1764100000000-CreateHostDiamondLedger';
import { CreateWeeklyDiamondTasks1764200000000 } from './migrations/1764200000000-CreateWeeklyDiamondTasks';
import { CreateGifts1764300000000 } from './migrations/1764300000000-CreateGifts';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT || 5432),
      username: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_DATABASE,

      ssl: {
        rejectUnauthorized: false,
      },

      autoLoadEntities: true,
      synchronize: false,

      migrationsRun: process.env.RUN_MIGRATIONS === 'true',

      migrations: [
        CreateCorePlatformTables1763855900000,
        AddUsdCurrencyFields1763856000000,
        CreateAgentCommissions1763857000000,
        CreateAuditLogs1763857100000,
        CreateRooms1763857200000,
        CreateRoomSeats1763857300000,
        ExpandRoomSeatLimit1763930000000,
        SeedHostLevels1764000000000,
        CreateHostDiamondLedger1764100000000,
        CreateWeeklyDiamondTasks1764200000000,
        CreateGifts1764300000000,
      ],
    }),
  ],
})
export class DatabaseModule {}
