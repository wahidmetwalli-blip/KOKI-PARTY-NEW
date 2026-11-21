import 'reflect-metadata';
import { DataSource } from 'typeorm';

const AppDataSource = new DataSource({
  type: 'postgres',

  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 5432),

  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'koki_party',

  entities: [
    __dirname + '/../**/*.entity{.js,.ts}',
  ],

  migrations: [
    __dirname + '/migrations/*{.js,.ts}',
  ],

  synchronize: false,
  migrationsRun: false,
  logging: false,
});

export default AppDataSource;
