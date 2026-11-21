import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum WithdrawalStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
  PAID = 'PAID',
  CANCELLED = 'CANCELLED',
}

export enum WithdrawalMethod {
  RECHARGE_AGENT = 'RECHARGE_AGENT',
  BANK_TRANSFER = 'BANK_TRANSFER',
  OTHER = 'OTHER',
}

@Entity('withdrawal_requests')
@Index(['hostUserId', 'status'])
export class WithdrawalRequest {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    name: 'host_user_id',
    type: 'uuid',
  })
  hostUserId: string;

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
    type: 'enum',
    enum: WithdrawalMethod,
  })
  method: WithdrawalMethod;

  @Column({
    type: 'enum',
    enum: WithdrawalStatus,
    default: WithdrawalStatus.PENDING,
  })
  status: WithdrawalStatus;

  @Column({
    name: 'assigned_agent_id',
    type: 'uuid',
    nullable: true,
  })
  assignedAgentId: string | null;

  @Column({
    name: 'payment_reference',
    type: 'varchar',
    length: 255,
    nullable: true,
    unique: true,
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

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;
}
