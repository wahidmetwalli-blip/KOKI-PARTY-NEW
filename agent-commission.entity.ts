
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

@Entity('agent_commissions')
@Index(['agentId', 'createdAt'])
@Index(['withdrawalRequestId'], { unique: true })
export class AgentCommission {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'agent_id', type: 'uuid' })
  agentId: string;

  @Column({ name: 'withdrawal_request_id', type: 'uuid' })
  withdrawalRequestId: string;

  @Column({ name: 'base_amount', type: 'bigint' })
  baseAmount: string;

  @Column({
    name: 'commission_rate',
    type: 'decimal',
    precision: 5,
    scale: 2,
  })
  commissionRate: string;

  @Column({ name: 'commission_amount', type: 'bigint' })
  commissionAmount: string;

  @Column({ type: 'varchar', length: 3, default: 'USD' })
  currency: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
