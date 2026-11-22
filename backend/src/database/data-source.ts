
import 'reflect-metadata';
import { DataSource } from 'typeorm';

const AppDataSource = new DataSource({
  type: 'postgres',

  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),

  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,

  ssl: {
    rejectUnauthorized: false,
  },

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
