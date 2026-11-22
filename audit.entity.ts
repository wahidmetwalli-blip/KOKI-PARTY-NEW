
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

@Entity('audit_logs')
@Index(['createdAt'])
@Index(['entityType', 'entityId'])
export class AuditLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    name: 'actor_user_id',
    type: 'uuid',
    nullable: true,
  })
  actorUserId: string | null;

  @Column({
    type: 'varchar',
    length: 100,
  })
  action: string;

  @Column({
    name: 'entity_type',
    type: 'varchar',
    length: 100,
  })
  entityType: string;

  @Column({
    name: 'entity_id',
    type: 'varchar',
    length: 100,
  })
  entityId: string;

  @Column({
    type: 'jsonb',
    nullable: true,
  })
  metadata: Record<string, unknown> | null;

  @CreateDateColumn({
    name: 'created_at',
    type: 'timestamp',
  })
  createdAt: Date;
}
