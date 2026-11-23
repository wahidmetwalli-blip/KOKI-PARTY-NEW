import 'reflect-metadata';
import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.setGlobalPrefix('api');

  app.enableCors({
    origin: true,
    credentials: true,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  const adminCandidates = [
    join(process.cwd(), 'admin'),
    join(process.cwd(), '..', 'admin'),
    join(__dirname, '..', '..', 'admin'),
    join(__dirname, '..', '..', '..', 'admin'),
  ];

  const adminDirectory = adminCandidates.find((directory) =>
    existsSync(join(directory, 'index.html')),
  );

  if (adminDirectory) {
    app.useStaticAssets(adminDirectory, { prefix: '/admin/' });
    console.log(`KOKI PARTY admin dashboard served from ${adminDirectory}`);
  } else {
    console.error('KOKI PARTY admin folder was not found:', adminCandidates);
  }

  const port = process.env.PORT || 3000;

  await app.listen(port, '0.0.0.0');

  console.log(`KOKI PARTY API running on port ${port}`);
}

bootstrap();
