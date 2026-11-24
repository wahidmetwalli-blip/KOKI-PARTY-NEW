
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

@Entity('gifts')
@Index(['isActive', 'sortOrder'])
export class Gift {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'varchar',
    length: 100,
  })
  name: string;

  @Column({
    type: 'varchar',
    length: 100,
    nullable: true,
  })
  nameEn: string | null;

  @Column({
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  description: string | null;

  @Column({
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  imageUrl: string | null;

  @Column({
    type: 'varchar',
    length: 20,
    nullable: true,
  })
  emoji: string | null;

  @Column({
    type: 'bigint',
    unsigned: false,
  })
  coinPrice: string;

  @Column({
    type: 'boolean',
    default: true,
  })
  isActive: boolean;

  @Column({
    type: 'integer',
    default: 0,
  })
  sortOrder: number;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;
}
