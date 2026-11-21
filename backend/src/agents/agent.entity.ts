import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum AgentType {
  HOST = 'HOST',
  RECHARGE = 'RECHARGE',
}

export enum AgentStatus {
  PENDING = 'PENDING',
  ACTIVE = 'ACTIVE',
  SUSPENDED = 'SUSPENDED',
}

@Entity('agents')
@Index(['userId', 'type'], { unique: true })
export class Agent {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({
    type: 'enum',
    enum: AgentType,
  })
  type: AgentType;

  @Column({
    type: 'enum',
    enum: AgentStatus,
    default: AgentStatus.PENDING,
  })
  status: AgentStatus;

  @Column({
    name: 'commission_rate',
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 0,
  })
  commissionRate: number;

  @Column({ name: 'total_earnings', type: 'bigint', default: 0 })
  totalEarnings: string;

  @Column({ name: 'total_recharged', type: 'bigint', default: 0 })
  totalRecharged: string;

  @Column({ name: 'total_withdrawn', type: 'bigint', default: 0 })
  totalWithdrawn: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  notes: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
