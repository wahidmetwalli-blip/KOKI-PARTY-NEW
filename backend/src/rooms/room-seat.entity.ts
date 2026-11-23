import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  Unique,
  Check,
} from 'typeorm';

@Entity('room_seats')
@Unique('uq_room_seats_room_number', ['roomId', 'seatNumber'])
@Unique('uq_room_seats_room_user', ['roomId', 'userId'])
@Check('chk_room_seats_number', '"seat_number" BETWEEN 1 AND 8')
export class RoomSeat {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'room_id', type: 'uuid' })
  roomId: string;

  @Column({ name: 'seat_number', type: 'smallint' })
  seatNumber: number;

  @Column({ name: 'user_id', type: 'uuid', nullable: true })
  userId: string | null;

  @Column({ name: 'is_muted', type: 'boolean', default: true })
  isMuted: boolean;

  @Column({ name: 'occupied_at', type: 'timestamp', nullable: true })
  occupiedAt: Date | null;
}
