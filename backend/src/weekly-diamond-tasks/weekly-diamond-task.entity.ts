
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum WeeklyDiamondPeriodStatus {
  OPEN = 'OPEN',
  PROCESSING = 'PROCESSING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
}

export enum WeeklyDiamondRewardStatus {
  PENDING = 'PENDING',
  PAID = 'PAID',
  FAILED = 'FAILED',
}

@Entity('weekly_diamond_task_periods')
@Index(['periodStart'], { unique: true })
@Index(['status', 'periodEnd'])
export class WeeklyDiamondTaskPeriod {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    name: 'period_start',
    type: 'timestamp',
  })
  periodStart: Date;

  @Column({
    name: 'period_end',
    type: 'timestamp',
  })
  periodEnd: Date;

  @Column({
    type: 'varchar',
    length: 50,
    default: 'Asia/Riyadh',
  })
  timezone: string;

  @Column({
    type: 'enum',
    enum: WeeklyDiamondPeriodStatus,
    enumName: 'weekly_diamond_period_status_enum',
    default: WeeklyDiamondPeriodStatus.OPEN,
  })
  status: WeeklyDiamondPeriodStatus;

  @Column({
    name: 'policy_version_id',
    type: 'uuid',
    nullable: true,
  })
  policyVersionId: string | null;

  @Column({
    name: 'total_hosts',
    type: 'integer',
    default: 0,
  })
  totalHosts: number;

  @Column({
    name: 'total_rewards',
    type: 'integer',
    default: 0,
  })
  totalRewards: number;

  @Column({
    name: 'total_coins',
    type: 'bigint',
    default: 0,
  })
  totalCoins: string;

  @Column({
    name: 'settlement_attempts',
    type: 'integer',
    default: 0,
  })
  settlementAttempts: number;

  @Column({
    name: 'last_error',
    type: 'varchar',
    length: 1000,
    nullable: true,
  })
  lastError: string | null;

  @Column({
    name: 'settled_at',
    type: 'timestamp',
    nullable: true,
  })
  settledAt: Date | null;

  @CreateDateColumn({
    name: 'created_at',
    type: 'timestamp',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
    type: 'timestamp',
  })
  updatedAt: Date;
}

@Entity('weekly_diamond_task_rewards')
@Index(
  ['periodId', 'hostUserId', 'taskLevel'],
  { unique: true },
)
@Index(['hostUserId', 'periodId'])
@Index(['status', 'createdAt'])
@Index(['periodId'])
@Index(['idempotencyKey'], { unique: true })
export class WeeklyDiamondTaskReward {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    name: 'period_id',
    type: 'uuid',
  })
  periodId: string;

  @Column({
    name: 'host_user_id',
    type: 'uuid',
  })
  hostUserId: string;

  @Column({
    name: 'task_level',
    type: 'integer',
  })
  taskLevel: number;

  @Column({
    name: 'required_diamonds',
    type: 'bigint',
  })
  requiredDiamonds: string;

  @Column({
    name: 'diamonds_received',
    type: 'bigint',
  })
  diamondsReceived: string;

  @Column({
    name: 'reward_coins',
    type: 'bigint',
  })
  rewardCoins: string;

  @Column({
    type: 'enum',
    enum: WeeklyDiamondRewardStatus,
    enumName: 'weekly_diamond_reward_status_enum',
    default: WeeklyDiamondRewardStatus.PENDING,
  })
  status: WeeklyDiamondRewardStatus;

  @Column({
    name: 'wallet_transaction_id',
    type: 'uuid',
    nullable: true,
  })
  walletTransactionId: string | null;

  @Column({
    name: 'idempotency_key',
    type: 'varchar',
    length: 150,
    unique: true,
  })
  idempotencyKey: string;

  @Column({
    name: 'failure_reason',
    type: 'varchar',
    length: 1000,
    nullable: true,
  })
  failureReason: string | null;

  @Column({
    name: 'paid_at',
    type: 'timestamp',
    nullable: true,
  })
  paidAt: Date | null;

  @CreateDateColumn({
    name: 'created_at',
    type: 'timestamp',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
    type: 'timestamp',
  })
  updatedAt: Date;
    }
