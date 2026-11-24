
import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateWeeklyDiamondTasks1764200000000
  implements MigrationInterface
{
  name = 'CreateWeeklyDiamondTasks1764200000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DO $$ BEGIN
        CREATE TYPE weekly_diamond_period_status_enum AS ENUM (
          'OPEN',
          'PROCESSING',
          'COMPLETED',
          'FAILED'
        );
      EXCEPTION
        WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE weekly_diamond_reward_status_enum AS ENUM (
          'PENDING',
          'PAID',
          'FAILED'
        );
      EXCEPTION
        WHEN duplicate_object THEN NULL;
      END $$;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS weekly_diamond_task_periods (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

        period_start timestamp NOT NULL,
        period_end timestamp NOT NULL,

        timezone varchar(50) NOT NULL
          DEFAULT 'Asia/Riyadh',

        status weekly_diamond_period_status_enum
          NOT NULL DEFAULT 'OPEN',

        policy_version_id uuid
          REFERENCES policy_versions(id)
          ON DELETE RESTRICT,

        total_hosts integer NOT NULL DEFAULT 0,
        total_rewards integer NOT NULL DEFAULT 0,
        total_coins bigint NOT NULL DEFAULT 0,

        settlement_attempts integer NOT NULL DEFAULT 0,
        last_error varchar(1000),

        settled_at timestamp,
        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now(),

        CONSTRAINT uq_weekly_diamond_period_start
          UNIQUE (period_start),

        CONSTRAINT chk_weekly_diamond_period_dates
          CHECK (period_end > period_start),

        CONSTRAINT chk_weekly_diamond_period_counts
          CHECK (
            total_hosts >= 0
            AND total_rewards >= 0
            AND total_coins >= 0
            AND settlement_attempts >= 0
          )
      );

      CREATE INDEX IF NOT EXISTS
        idx_weekly_diamond_period_status
      ON weekly_diamond_task_periods(status, period_end);
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS weekly_diamond_task_rewards (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

        period_id uuid NOT NULL
          REFERENCES weekly_diamond_task_periods(id)
          ON DELETE RESTRICT,

        host_user_id uuid NOT NULL
          REFERENCES users(id)
          ON DELETE RESTRICT,

        task_level integer NOT NULL,

        required_diamonds bigint NOT NULL,
        diamonds_received bigint NOT NULL,
        reward_coins bigint NOT NULL,

        status weekly_diamond_reward_status_enum
          NOT NULL DEFAULT 'PENDING',

        wallet_transaction_id uuid
          REFERENCES wallet_transactions(id)
          ON DELETE RESTRICT,

        idempotency_key varchar(150) NOT NULL UNIQUE,

        failure_reason varchar(1000),

        paid_at timestamp,
        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now(),

        CONSTRAINT uq_weekly_reward_host_level
          UNIQUE (period_id, host_user_id, task_level),

        CONSTRAINT chk_weekly_reward_values
          CHECK (
            task_level > 0
            AND required_diamonds > 0
            AND diamonds_received >= required_diamonds
            AND reward_coins > 0
          )
      );

      CREATE INDEX IF NOT EXISTS
        idx_weekly_rewards_host_period
      ON weekly_diamond_task_rewards(
        host_user_id,
        period_id
      );

      CREATE INDEX IF NOT EXISTS
        idx_weekly_rewards_status
      ON weekly_diamond_task_rewards(status, created_at);

      CREATE INDEX IF NOT EXISTS
        idx_weekly_rewards_period
      ON weekly_diamond_task_rewards(period_id);
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    throw new Error(
      'Rollback disabled to protect weekly diamond reward records.',
    );
  }
}
