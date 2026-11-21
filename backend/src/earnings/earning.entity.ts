import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

export enum EarningSource {
  GIFT = 'GIFT',
  ROOM_REWARD = 'ROOM_REWARD',
  BONUS = 'BONUS',
}

export enum EarningStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  PAID = 'PAID',
  CANCELLED = 'CANCELLED',
}

@Entity('host_earnings')
@Index(['hostUserId', 'createdAt'])
@Index(['reference'], { unique: true })
export class HostEarning {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    name: 'host_user_id',
    type: 'uuid',
  })
  hostUserId: string;

  @Column({
    type: 'enum',
    enum: EarningSource,
  })
  source: EarningSource;

  @Column({
    type: 'enum',
    enum: EarningStatus,
    default: EarningStatus.PENDING,
  })
  status: EarningStatus;

  @Column({
    type: 'bigint',
  })
  amount: string;

  @Column({
    type: 'varchar',
    length: 150,
    unique: true,
  })
  reference: string;

  @Column({
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  description: string | null;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;
}
