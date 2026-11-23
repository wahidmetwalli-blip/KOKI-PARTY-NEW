
import { MigrationInterface, QueryRunner } from 'typeorm';

export class ExpandRoomSeatLimit1763930000000
  implements MigrationInterface {
  name = 'ExpandRoomSeatLimit1763930000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE room_seats
      DROP CONSTRAINT IF EXISTS chk_room_seats_number;
    `);

    await queryRunner.query(`
      ALTER TABLE room_seats
      ADD CONSTRAINT chk_room_seats_number
      CHECK (seat_number BETWEEN 1 AND 20);
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    throw new Error(
      'Rollback disabled to protect room seat data.',
    );
  }
                            }
