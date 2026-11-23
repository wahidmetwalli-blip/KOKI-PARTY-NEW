
import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateRooms1763857200000
  implements MigrationInterface {
  name = 'CreateRooms1763857200000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS rooms (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        name varchar(120) NOT NULL,
        description varchar(500),
        owner_user_id uuid NOT NULL
          REFERENCES users(id) ON DELETE RESTRICT,
        cover_url varchar(500),
        max_seats integer NOT NULL DEFAULT 8,
        is_active boolean NOT NULL DEFAULT true,
        created_at timestamp NOT NULL DEFAULT now(),
        updated_at timestamp NOT NULL DEFAULT now(),
        CONSTRAINT chk_rooms_max_seats
          CHECK (max_seats BETWEEN 1 AND 8)
      );

      CREATE INDEX IF NOT EXISTS idx_rooms_owner
        ON rooms(owner_user_id);

      CREATE INDEX IF NOT EXISTS idx_rooms_active_created
        ON rooms(is_active, created_at);
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    throw new Error(
      'Rollback disabled to protect project data.',
    );
  }
  }
