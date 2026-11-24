
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

@Entity('host_diamond_ledger')
@Index(['hostUserId', 'createdAt'])
@Index(['reference'], { unique: true })
export class HostDiamondLedger {
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
    length: 50,
  })
  source: string;

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
    type: 'timestamp',
  })
  createdAt: Date;
}
