
import {
  MigrationInterface,
  QueryRunner,
  Table,
  TableIndex,
} from 'typeorm';

export class CreateAuditLogs1763857000000
  implements MigrationInterface
{
  name = 'CreateAuditLogs1763857000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    if (await queryRunner.hasTable('audit_logs')) {
      return;
    }

    await queryRunner.createTable(
      new Table({
        name: 'audit_logs',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'gen_random_uuid()',
          },
          {
            name: 'actor_user_id',
            type: 'uuid',
            isNullable: true,
          },
          {
            name: 'action',
            type: 'varchar',
            length: '100',
          },
          {
            name: 'entity_type',
            type: 'varchar',
            length: '100',
          },
          {
            name: 'entity_id',
            type: 'varchar',
            length: '100',
          },
          {
            name: 'metadata',
            type: 'jsonb',
            isNullable: true,
          },
          {
            name: 'created_at',
            type: 'timestamp',
            default: 'CURRENT_TIMESTAMP',
          },
        ],
      }),
    );

    await queryRunner.createIndex(
      'audit_logs',
      new TableIndex({
        name: 'IDX_audit_logs_created_at',
        columnNames: ['created_at'],
      }),
    );

    await queryRunner.createIndex(
      'audit_logs',
      new TableIndex({
        name: 'IDX_audit_logs_entity',
        columnNames: ['entity_type', 'entity_id'],
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    if (await queryRunner.hasTable('audit_logs')) {
      await queryRunner.dropTable('audit_logs');
    }
  }
}
