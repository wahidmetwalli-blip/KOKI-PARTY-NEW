
import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateCorePlatformTables1763855900000
  implements MigrationInterface
{
  name = 'CreateCorePlatformTables1763855900000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE EXTENSION IF NOT EXISTS pgcrypto;

      DO $$ BEGIN
        CREATE TYPE users_role_enum AS ENUM (
          'OWNER', 'SUPER_ADMIN', 'ADMIN', 'MODERATOR',
          'HOST_AGENT', 'RESELLER', 'HOST', 'USER'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE agents_type_enum AS ENUM ('HOST', 'RECHARGE');
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE agents_status_enum AS ENUM (
          'PENDING', 'ACTIVE', 'SUSPENDED'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE agencies_status_enum AS ENUM (
          'ACTIVE', 'SUSPENDED'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE agency_members_activity_enum AS ENUM (
          'HOST', 'RECHARGE'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE wallet_transactions_type_enum AS ENUM (
          'CREDIT', 'DEBIT'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE host_earnings_source_enum AS ENUM (
          'GIFT', 'ROOM_REWARD', 'BONUS'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE host_earnings_status_enum AS ENUM (
          'PENDING', 'APPROVED', 'WITHDRAWAL_REQUESTED',
          'PAID', 'CANCELLED'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE withdrawal_requests_method_enum AS ENUM (
          'RECHARGE_AGENT', 'BANK_TRANSFER', 'OTHER'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE withdrawal_requests_status_enum AS ENUM (
          'PENDING', 'APPROVED', 'REJECTED', 'PAID', 'CANCELLED'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE agent_payouts_status_enum AS ENUM (
          'PENDING', 'APPROVED', 'PAID', 'REJECTED', 'CANCELLED'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE policy_versions_category_enum AS ENUM (
          'HOST_LEVELS', 'AGENCY_LEVELS', 'AGENCY_OPENING',
          'RECHARGE_PLAN_A', 'RECHARGE_PLAN_B', 'FIRST_RECHARGE',
          'ROOM_WEEKLY_REWARDS', 'DIAMOND_TASKS',
          'WITHDRAWAL_RULES', 'COMMISSIONS'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;

      DO $$ BEGIN
        CREATE TYPE policy_versions_status_enum AS ENUM (
          'DRAFT', 'ACTIVE', 'ARCHIVED'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS users (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        email varchar(120) UNIQUE,
        phone varchar(30) UNIQUE,
        password_hash varchar(255) NOT NULL,
        role users_role_enum NOT NULL DEFAULT 'USER',
        permissions jsonb NOT NULL DEFAULT '[]'::jsonb,
        is_active boolean NOT NULL DEFAULT true,
        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS agents (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
        type agents_type_enum NOT NULL,
        status agents_status_enum NOT NULL DEFAULT 'PENDING',
        commission_rate decimal(5,2) NOT NULL DEFAULT 0,
        total_earnings bigint NOT NULL DEFAULT 0,
        total_recharged bigint NOT NULL DEFAULT 0,
        total_withdrawn bigint NOT NULL DEFAULT 0,
        notes varchar(500),
        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now(),
        CONSTRAINT uq_agents_user_type UNIQUE (user_id, type)
      );

      CREATE TABLE IF NOT EXISTS agencies (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        name varchar(120) NOT NULL,
        code varchar(60) NOT NULL UNIQUE,
        description text,
        status agencies_status_enum NOT NULL DEFAULT 'ACTIVE',
        created_by uuid REFERENCES users(id) ON DELETE SET NULL,
        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS agency_members (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
        agent_id uuid NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
        activity agency_members_activity_enum NOT NULL,
        member_role varchar(30) NOT NULL DEFAULT 'MEMBER',
        is_primary boolean NOT NULL DEFAULT false,
        created_at timestamp NOT NULL DEFAULT now(),
        CONSTRAINT uq_agency_member_activity
          UNIQUE (agency_id, agent_id, activity)
      );

      CREATE TABLE IF NOT EXISTS wallets (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id uuid NOT NULL UNIQUE REFERENCES users(id) ON DELETE RESTRICT,
        coin_balance bigint NOT NULL DEFAULT 0,
        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS wallet_transactions (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        wallet_id uuid NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
        type wallet_transactions_type_enum NOT NULL,
        amount bigint NOT NULL,
        balance_before bigint NOT NULL,
        balance_after bigint NOT NULL,
        reference varchar(150),
        idempotency_key varchar(150) UNIQUE,
        description varchar(500),
        created_at timestamp NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS host_levels (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        level integer NOT NULL UNIQUE,
        required_diamonds bigint NOT NULL,
        diamond_rate decimal(5,2) NOT NULL DEFAULT 100,
        host_salary_usd_cents bigint NOT NULL,
        salary_currency varchar(3) NOT NULL DEFAULT 'USD',
        vip_level integer NOT NULL DEFAULT 0,
        system_display boolean NOT NULL DEFAULT true,
        is_active boolean NOT NULL DEFAULT true,
        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS withdrawal_requests (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        host_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
        amount bigint NOT NULL,
        currency varchar(3) NOT NULL DEFAULT 'USD',
        method withdrawal_requests_method_enum NOT NULL,
        status withdrawal_requests_status_enum NOT NULL DEFAULT 'PENDING',
        assigned_agent_id uuid REFERENCES agents(id) ON DELETE SET NULL,
        payment_reference varchar(255) UNIQUE,
        reviewed_by uuid REFERENCES users(id) ON DELETE SET NULL,
        review_note text,
        paid_at timestamp,
        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS host_earnings (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        host_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
        source host_earnings_source_enum NOT NULL,
        status host_earnings_status_enum NOT NULL DEFAULT 'PENDING',
        amount bigint NOT NULL,
        currency varchar(3) NOT NULL DEFAULT 'USD',
        reference varchar(150) NOT NULL UNIQUE,
        withdrawal_request_id uuid REFERENCES withdrawal_requests(id) ON DELETE SET NULL,
        description varchar(500),
        created_at timestamp NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS agent_payouts (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        agent_id uuid NOT NULL REFERENCES agents(id) ON DELETE RESTRICT,
        amount bigint NOT NULL,
        currency varchar(3) NOT NULL DEFAULT 'USD',
        status agent_payouts_status_enum NOT NULL DEFAULT 'PENDING',
        payment_reference varchar(255) UNIQUE,
        reviewed_by uuid REFERENCES users(id) ON DELETE SET NULL,
        review_note text,
        paid_at timestamp,
        created_at timestamp NOT NULL DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS policy_versions (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        category policy_versions_category_enum NOT NULL,
        version integer NOT NULL,
        status policy_versions_status_enum NOT NULL DEFAULT 'DRAFT',
        rules jsonb NOT NULL DEFAULT '{}'::jsonb,
        description varchar(500),
        effective_from timestamp,
        effective_until timestamp,
        created_by uuid REFERENCES users(id) ON DELETE SET NULL,
        approved_by uuid REFERENCES users(id) ON DELETE SET NULL,
        approved_at timestamp,
        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now(),
        CONSTRAINT uq_policy_category_version UNIQUE (category, version)
      );
    `);

    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_agents_user
        ON agents(user_id);

      CREATE INDEX IF NOT EXISTS idx_agency_members_agent
        ON agency_members(agent_id);

      CREATE INDEX IF NOT EXISTS idx_agency_members_activity
        ON agency_members(activity);

      CREATE INDEX IF NOT EXISTS idx_wallet_transactions_wallet_created
        ON wallet_transactions(wallet_id, created_at);

      CREATE INDEX IF NOT EXISTS idx_host_earnings_host_created
        ON host_earnings(host_user_id, created_at);

      CREATE INDEX IF NOT EXISTS idx_withdrawals_host_status
        ON withdrawal_requests(host_user_id, status);

      CREATE INDEX IF NOT EXISTS idx_agent_payouts_agent_created
        ON agent_payouts(agent_id, created_at);

      CREATE INDEX IF NOT EXISTS idx_policy_category_status
        ON policy_versions(category, status);
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    throw new Error(
      'Rollback disabled to protect project data.',
    );
  }
}
