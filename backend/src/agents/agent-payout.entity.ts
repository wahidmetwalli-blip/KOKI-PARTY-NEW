import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

export enum AgentPayoutStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  PAID = 'PAID',
  REJECTED = 'REJECTED',
  CANCELLED = 'CANCELLED',
}

@Entity('agent_payouts')
@Index(['agentId', 'createdAt'])
@Index(['paymentReference'], { unique: true })
export class AgentPayout {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'agent_id', type: 'uuid' })
  agentId: string;

  // Amount stored in USD cents.
  @Column({ type: 'bigint' })
  amount: string;

  @Column({
    type: 'varchar',
    length: 3,
    default: 'USD',
  })
  currency: string;

  @Column({
    type: 'enum',
    enum: AgentPayoutStatus,
    default: AgentPayoutStatus.PENDING,
  })
  status: AgentPayoutStatus;

  @Column({
    name: 'payment_reference',
    type: 'varchar',
    length: 255,
    nullable: true,
  })
  paymentReference: string | null;

  @Column({
    name: 'reviewed_by',
    type: 'uuid',
    nullable: true,
  })
  reviewedBy: string | null;

  @Column({
    name: 'review_note',
    type: 'text',
    nullable: true,
  })
  reviewNote: string | null;

  @Column({
    name: 'paid_at',
    type: 'timestamp',
    nullable: true,
  })
  paidAt: Date | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
