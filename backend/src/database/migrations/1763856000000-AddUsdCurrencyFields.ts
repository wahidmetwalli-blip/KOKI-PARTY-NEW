import {
  MigrationInterface,
  QueryRunner,
  TableColumn,
} from 'typeorm';

export class AddUsdCurrencyFields1763856000000
  implements MigrationInterface
{
  name = 'AddUsdCurrencyFields1763856000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    const requiredTables = [
      'host_levels',
      'host_earnings',
      'withdrawal_requests',
    ];

    for (const tableName of requiredTables) {
      if (!(await queryRunner.hasTable(tableName))) {
        throw new Error(
          `Required table "${tableName}" does not exist. Migration stopped.`,
        );
      }
    }

    const hostLevels = await queryRunner.getTable('host_levels');

    if (!hostLevels) {
      throw new Error('Could not inspect host_levels table.');
    }

    if (!hostLevels.findColumnByName('host_salary_usd_cents')) {
      throw new Error(
        'host_salary_usd_cents is missing. Refusing to guess or convert salary data.',
      );
    }

    if (!hostLevels.findColumnByName('salary_currency')) {
      await queryRunner.addColumn(
        'host_levels',
        new TableColumn({
          name: 'salary_currency',
          type: 'varchar',
          length: '3',
          isNullable: false,
          default: "'USD'",
        }),
      );
    }

    for (const tableName of [
      'host_earnings',
      'withdrawal_requests',
    ]) {
      const table = await queryRunner.getTable(tableName);

      if (!table) {
        throw new Error(`Could not inspect ${tableName}.`);
      }

      if (!table.findColumnByName('currency')) {
        await queryRunner.addColumn(
          tableName,
          new TableColumn({
            name: 'currency',
            type: 'varchar',
            length: '3',
            isNullable: false,
            default: "'USD'",
          }),
        );
      }
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    for (const tableName of [
      'withdrawal_requests',
      'host_earnings',
    ]) {
      const table = await queryRunner.getTable(tableName);

      if (table?.findColumnByName('currency')) {
        await queryRunner.dropColumn(tableName, 'currency');
      }
    }

    const hostLevels = await queryRunner.getTable('host_levels');

    if (hostLevels?.findColumnByName('salary_currency')) {
      await queryRunner.dropColumn(
        'host_levels',
        'salary_currency',
      );
    }
  }
}
