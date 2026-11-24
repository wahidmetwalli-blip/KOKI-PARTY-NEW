import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateHostDiamondLedger1764100000000
  implements MigrationInterface
{
  name = 'CreateHostDiamondLedger1764100000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS host_diamond_ledger (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        host_user_id uuid NOT NULL
          REFERENCES users(id) ON DELETE RESTRICT,
        amount bigint NOT NULL CHECK (amount > 0),
        source varchar(50) NOT NULL,
        reference varchar(150) NOT NULL UNIQUE,
        description varchar(500),
        created_at timestamp NOT NULL DEFAULT now()
      );

      CREATE INDEX IF NOT EXISTS idx_host_diamond_ledger_host_date
      ON host_diamond_ledger(host_user_id, created_at);
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    throw new Error(
      'Rollback disabled to protect host diamond records.',
    );
  }
}
