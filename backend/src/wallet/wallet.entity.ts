import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

export enum WalletTransactionType {
  CREDIT = 'CREDIT',
  DEBIT = 'DEBIT',
}

@Entity('wallets')
@Index(['userId'], { unique: true })
export class Wallet {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({
    name: 'coin_balance',
    type: 'bigint',
    default: 0,
  })
  coinBalance: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

@Entity('wallet_transactions')
@Index(['idempotencyKey'], { unique: true })
@Index(['walletId', 'createdAt'])
export class WalletTransaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'wallet_id', type: 'uuid' })
  walletId: string;

  @Column({
    type: 'enum',
    enum: WalletTransactionType,
  })
  type: WalletTransactionType;

  @Column({ type: 'bigint' })
  amount: string;

  @Column({ name: 'balance_before', type: 'bigint' })
  balanceBefore: string;

  @Column({ name: 'balance_after', type: 'bigint' })
  balanceAfter: string;

  @Column({
    type: 'varchar',
    length: 150,
    nullable: true,
  })
  reference: string | null;

  @Column({
    name: 'idempotency_key',
    type: 'varchar',
    length: 150,
    nullable: true,
  })
  idempotencyKey: string | null;

  @Column({
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  description: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
