
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
  WITHDRAWAL_REQUESTED = 'WITHDRAWAL_REQUESTED',
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

  // Amount is stored in USD cents.
  // 1000 cents = 10 USD.
  @Column({
    type: 'bigint',
  })
  amount: string;

  @Column({
    type: 'varchar',
    length: 3,
    default: 'USD',
  })
  currency: string;

  @Column({
    type: 'varchar',
    length: 150,
    unique: true,
  })
  reference: string;

  @Column({
    name: 'withdrawal_request_id',
    type: 'uuid',
    nullable: true,
  })
  withdrawalRequestId: string | null;

  @Column({
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  description: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
