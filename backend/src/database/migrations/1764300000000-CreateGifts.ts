
import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateGifts1764300000000
  implements MigrationInterface
{
  name = 'CreateGifts1764300000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS gifts (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

        name varchar(100) NOT NULL,
        "nameEn" varchar(100),
        description varchar(500),
        "imageUrl" varchar(500),
        emoji varchar(20),

        "coinPrice" bigint NOT NULL,

        "isActive" boolean NOT NULL DEFAULT true,
        "sortOrder" integer NOT NULL DEFAULT 0,

        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now(),

        CONSTRAINT chk_gifts_coin_price
          CHECK ("coinPrice" > 0),

        CONSTRAINT chk_gifts_sort_order
          CHECK ("sortOrder" >= 0)
      );

      CREATE INDEX IF NOT EXISTS
        idx_gifts_active_sort
      ON gifts("isActive", "sortOrder");
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    throw new Error(
      'Rollback disabled to protect gift catalog records.',
    );
  }
}
