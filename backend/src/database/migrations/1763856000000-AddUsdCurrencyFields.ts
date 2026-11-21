import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUsdCurrencyFields1763856000000
  implements MigrationInterface
{
  name = 'AddUsdCurrencyFields1763856000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    const tables = [
      'host_levels',
      'host_earnings',
      'withdrawal_requests',
    ];

    for (const table of tables) {
      const exists = await queryRunner.hasTable(table);

      if (!exists) {
        continue;
      }

      const hasCurrency = await queryRunner.hasColumn(
        table,
        'currency',
      );

      if (!hasCurrency && table !== 'host_levels') {
        await queryRunner.query(
          `ALTER TABLE "${table}"
           ADD COLUMN "currency" varchar(3) NOT NULL DEFAULT 'USD'`,
        );
      }
    }

    if (await queryRunner.hasTable('host_levels')) {
      const hasSalaryCurrency =
        await queryRunner.hasColumn(
          'host_levels',
          'salary_currency',
        );

      if (!hasSalaryCurrency) {
        await queryRunner.query(
          `ALTER TABLE "host_levels"
           ADD COLUMN "salary_currency" varchar(3) NOT NULL DEFAULT 'USD'`,
        );
      }
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    if (await queryRunner.hasTable('host_levels')) {
      if (
        await queryRunner.hasColumn(
          'host_levels',
          'salary_currency',
        )
      ) {
        await queryRunner.query(
          `ALTER TABLE "host_levels"
           DROP COLUMN "salary_currency"`,
        );
      }
    }

    for (const table of [
      'withdrawal_requests',
      'host_earnings',
    ]) {
      if (await queryRunner.hasTable(table)) {
        if (
          await queryRunner.hasColumn(table, 'currency')
        ) {
          await queryRunner.query(
            `ALTER TABLE "${table}" DROP COLUMN "currency"`,
          );
        }
      }
    }
  }
}
