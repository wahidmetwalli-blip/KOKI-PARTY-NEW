import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum PolicyStatus {
  DRAFT = 'DRAFT',
  ACTIVE = 'ACTIVE',
  ARCHIVED = 'ARCHIVED',
}

export enum PolicyCategory {
  HOST_LEVELS = 'HOST_LEVELS',
  AGENCY_LEVELS = 'AGENCY_LEVELS',
  AGENCY_OPENING = 'AGENCY_OPENING',
  RECHARGE_PLAN_A = 'RECHARGE_PLAN_A',
  RECHARGE_PLAN_B = 'RECHARGE_PLAN_B',
  FIRST_RECHARGE = 'FIRST_RECHARGE',
  ROOM_WEEKLY_REWARDS = 'ROOM_WEEKLY_REWARDS',
  DIAMOND_TASKS = 'DIAMOND_TASKS',
  WITHDRAWAL_RULES = 'WITHDRAWAL_RULES',
  COMMISSIONS = 'COMMISSIONS',
}

@Entity('policy_versions')
@Index(['category', 'version'], { unique: true })
@Index(['category', 'status'])
export class PolicyVersion {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: PolicyCategory,
  })
  category: PolicyCategory;

  @Column({
    type: 'integer',
  })
  version: number;

  @Column({
    type: 'enum',
    enum: PolicyStatus,
    default: PolicyStatus.DRAFT,
  })
  status: PolicyStatus;

  @Column({
    type: 'jsonb',
    default: () => "'{}'::jsonb",
  })
  rules: Record<string, any>;

  @Column({
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  description: string | null;

  @Column({
    name: 'effective_from',
    type: 'timestamp',
    nullable: true,
  })
  effectiveFrom: Date | null;

  @Column({
    name: 'effective_until',
    type: 'timestamp',
    nullable: true,
  })
  effectiveUntil: Date | null;

  @Column({
    name: 'created_by',
    type: 'uuid',
    nullable: true,
  })
  createdBy: string | null;

  @Column({
    name: 'approved_by',
    type: 'uuid',
    nullable: true,
  })
  approvedBy: string | null;

  @Column({
    name: 'approved_at',
    type: 'timestamp',
    nullable: true,
  })
  approvedAt: Date | null;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;
    }
