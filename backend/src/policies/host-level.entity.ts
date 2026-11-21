
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

@Entity('host_levels')
@Index(['level'], { unique: true })
export class HostLevel {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'integer',
    unique: true,
  })
  level: number;

  @Column({
    name: 'required_diamonds',
    type: 'bigint',
  })
  requiredDiamonds: string;

  @Column({
    name: 'diamond_rate',
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 100,
  })
  diamondRate: string;

  @Column({
    name: 'host_salary_usd_cents',
    type: 'bigint',
  })
  hostSalaryUsdCents: string;

  @Column({
    name: 'salary_currency',
    type: 'varchar',
    length: 3,
    default: 'USD',
  })
  salaryCurrency: string;

  @Column({
    name: 'vip_level',
    type: 'integer',
    default: 0,
  })
  vipLevel: number;

  @Column({
    name: 'system_display',
    type: 'boolean',
    default: true,
  })
  systemDisplay: boolean;

  @Column({
    type: 'boolean',
    default: true,
  })
  isActive: boolean;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;
}
