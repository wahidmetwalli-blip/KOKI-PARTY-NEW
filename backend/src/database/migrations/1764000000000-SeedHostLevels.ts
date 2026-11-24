
import { MigrationInterface, QueryRunner } from 'typeorm';

export class SeedHostLevels1764000000000
  implements MigrationInterface
{
  name = 'SeedHostLevels1764000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    const levels = [
      [1, '2000000', '1000'],
      [2, '4000000', '2000'],
      [3, '6000000', '3000'],
      [4, '10000000', '5000'],
      [5, '14000000', '7000'],
      [6, '20000000', '10000'],
      [7, '26000000', '13000'],
      [8, '40000000', '20000'],
      [9, '60000000', '30000'],
      [10, '200000000', '100000'],
      [11, '600000000', '300000'],
      [12, '1200000000', '600000'],
    ];

    for (const [level, diamonds, salaryCents] of levels) {
      await queryRunner.query(
        `INSERT INTO host_levels
          (level, required_diamonds, diamond_rate,
           host_salary_usd_cents, salary_currency,
           vip_level, system_display, is_active)
         VALUES ($1, $2, 100, $3, 'USD', 0, true, true)
         ON CONFLICT (level) DO NOTHING`,
        [level, diamonds, salaryCents],
      );
    }
  }

  public async down(): Promise<void> {
    // لا نحذف بيانات المستويات عند التراجع حفاظاً على البيانات.
  }
}
