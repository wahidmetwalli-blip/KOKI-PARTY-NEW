
import {
  MigrationInterface,
  QueryRunner,
  Table,
  TableIndex,
} from 'typeorm';

export class CreateAgentCommissions1763857000000
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    if (await queryRunner.hasTable('agent_commissions')) {
      return;
    }

    await queryRunner.createTable(
      new Table({
        name: 'agent_commissions',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            default: 'gen_random_uuid()',
          },
          {
            name: 'agent_id',
            type: 'uuid',
            isNullable: false,
          },
          {
            name: 'withdrawal_request_id',
            type: 'uuid',
            isNullable: false,
          },
          {
            name: 'base_amount',
            type: 'bigint',
            isNullable: false,
          },
          {
            name: 'commission_rate',
            type: 'decimal',
            precision: 5,
            scale: 2,
            isNullable: false,
          },
          {
            name: 'commission_amount',
            type: 'bigint',
            isNullable: false,
          },
          {
            name: 'currency',
            type: 'varchar',
            length: '3',
            default: "'USD'",
          },
          {
            name: 'created_at',
            type: 'timestamp',
            default: 'now()',
          },
        ],
      }),
    );

    await queryRunner.createIndex(
      'agent_commissions',
      new TableIndex({
        name: 'IDX_agent_commissions_agent_created',
        columnNames: ['agent_id', 'created_at'],
      }),
    );

    await queryRunner.createIndex(
      'agent_commissions',
      new TableIndex({
        name: 'UQ_agent_commissions_withdrawal',
        columnNames: ['withdrawal_request_id'],
        isUnique: true,
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    if (await queryRunner.hasTable('agent_commissions')) {
      await queryRunner.dropTable('agent_commissions');
    }
  }
          }
