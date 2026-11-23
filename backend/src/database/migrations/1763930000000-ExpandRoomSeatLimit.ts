import { MigrationInterface, QueryRunner } from 'typeorm';

export class ExpandRoomSeatLimit1763930000000
  implements MigrationInterface {
  name = 'ExpandRoomSeatLimit1763930000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE rooms
      DROP CONSTRAINT IF EXISTS chk_rooms_max_seats;
    `);

    await queryRunner.query(`
      ALTER TABLE rooms
      ADD CONSTRAINT chk_rooms_max_seats
      CHECK (max_seats BETWEEN 1 AND 20);
    `);

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
      'Rollback disabled to protect room and seat data.',
    );
  }
}
