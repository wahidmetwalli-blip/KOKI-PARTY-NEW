import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateRoomSeats1763857300000
  implements MigrationInterface {
  name = 'CreateRoomSeats1763857300000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS room_seats (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        room_id uuid NOT NULL
          REFERENCES rooms(id) ON DELETE CASCADE,
        seat_number smallint NOT NULL,
        user_id uuid NULL
          REFERENCES users(id) ON DELETE SET NULL,
        is_muted boolean NOT NULL DEFAULT true,
        occupied_at timestamp NULL,

        CONSTRAINT uq_room_seats_room_number
          UNIQUE (room_id, seat_number),

        CONSTRAINT uq_room_seats_room_user
          UNIQUE (room_id, user_id),

        CONSTRAINT chk_room_seats_number
          CHECK (seat_number BETWEEN 1 AND 8)
      );

      CREATE INDEX IF NOT EXISTS idx_room_seats_room
        ON room_seats(room_id);

      INSERT INTO room_seats (room_id, seat_number)
      SELECT rooms.id, seats.seat_number
      FROM rooms
      CROSS JOIN generate_series(1, 8) AS seats(seat_number)
      ON CONFLICT (room_id, seat_number) DO NOTHING;
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    throw new Error(
      'Rollback disabled to protect project data.',
    );
  }
  }
