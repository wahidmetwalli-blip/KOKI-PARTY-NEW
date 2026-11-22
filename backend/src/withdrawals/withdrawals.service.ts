
import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { DataSource } from 'typeorm';

import {
  HostEarning,
  EarningStatus,
} from '../earnings/earning.entity';

import {
  WithdrawalRequest,
  WithdrawalMethod,
  WithdrawalStatus,
} from './withdrawal.entity';

import {
  Agent,
  AgentType,
  AgentStatus,
} from '../agents/agent.entity';

@Injectable()
export class WithdrawalsService {
  constructor(
    private readonly dataSource: DataSource,
  ) {}

  async createWithdrawal(
    hostUserId: string,
    amount: string,
    method: WithdrawalMethod,
  ) {
    if (
      typeof amount !== 'string' ||
      !/^[1-9]\d*$/.test(amount)
    ) {
      throw new BadRequestException(
        'Amount must be a positive integer in USD cents',
      );
    }

    if (!Object.values(WithdrawalMethod).includes(method)) {
      throw new BadRequestException('Invalid withdrawal method');
    }

    const requestedAmount = BigInt(amount);

    return this.dataSource.transaction(async (manager) => {
      const earningsRepo = manager.getRepository(HostEarning);
      const withdrawalsRepo = manager.getRepository(WithdrawalRequest);

      const earnings = await earningsRepo
        .createQueryBuilder('earning')
        .setLock('pessimistic_write')
        .where('earning.hostUserId = :hostUserId', { hostUserId })
        .andWhere('earning.status = :status', {
          status: EarningStatus.APPROVED,
        })
        .andWhere('earning.withdrawalRequestId IS NULL')
        .orderBy('earning.createdAt', 'ASC')
        .getMany();

      let total = 0n;
      const selected: HostEarning[] = [];

      for (const earning of earnings) {
        const value = BigInt(earning.amount);

        if (value <= 0n) {
          throw new BadRequestException('Invalid earning amount');
        }

        if (total + value <= requestedAmount) {
          selected.push(earning);
          total += value;
        }

        if (total === requestedAmount) break;
      }

      if (total !== requestedAmount) {
        throw new BadRequestException(
          'Insufficient approved earnings or amount does not match available records',
        );
      }

      const withdrawal = withdrawalsRepo.create({
        hostUserId,
        amount,
        currency: 'USD',
        method,
        status: WithdrawalStatus.PENDING,
        assignedAgentId: null,
        paymentReference: null,
        reviewedBy: null,
        reviewNote: null,
        paidAt: null,
      });

      const saved = await withdrawalsRepo.save(withdrawal);

      for (const earning of selected) {
        earning.status = EarningStatus.WITHDRAWAL_REQUESTED;
        earning.withdrawalRequestId = saved.id;
      }

      await earningsRepo.save(selected);

      return saved;
    });
  }

  async getMyWithdrawals(hostUserId: string) {
    return this.dataSource.getRepository(WithdrawalRequest).find({
      where: { hostUserId },
      order: { createdAt: 'DESC' },
      take: 100,
    });
  }

  async getWithdrawalById(
    hostUserId: string,
    withdrawalId: string,
  ) {
    const withdrawal = await this.dataSource
      .getRepository(WithdrawalRequest)
      .findOne({
        where: { id: withdrawalId, hostUserId },
      });

    if (!withdrawal) {
      throw new NotFoundException('Withdrawal request not found');
    }

    return withdrawal;
  }

  async adminList(status?: WithdrawalStatus) {
    return this.dataSource.getRepository(WithdrawalRequest).find({
      where: status ? { status } : {},
      order: { createdAt: 'DESC' },
      take: 200,
    });
  }

  async approveWithdrawal(
    id: string,
    adminId: string,
    note?: string,
  ) {
    return this.dataSource.transaction(async (manager) => {
      const repo = manager.getRepository(WithdrawalRequest);

      const request = await repo
        .createQueryBuilder('withdrawal')
        .setLock('pessimistic_write')
        .where('withdrawal.id = :id', { id })
        .getOne();

      if (!request) {
        throw new NotFoundException('Withdrawal not found');
      }

      if (request.status !== WithdrawalStatus.PENDING) {
        throw new ConflictException(
          'Only pending requests can be approved',
        );
      }

      request.status = WithdrawalStatus.APPROVED;
      request.reviewedBy = adminId;
      request.reviewNote = note?.trim() || null;

      return repo.save(request);
    });
  }

  async rejectWithdrawal(
    id: string,
    adminId: string,
    note: string,
  ) {
    if (!note || !note.trim()) {
      throw new BadRequestException(
        'A rejection reason is required',
      );
    }

    return this.dataSource.transaction(async (manager) => {
      const withdrawalsRepo = manager.getRepository(WithdrawalRequest);
      const earningsRepo = manager.getRepository(HostEarning);

      const request = await withdrawalsRepo
        .createQueryBuilder('withdrawal')
        .setLock('pessimistic_write')
        .where('withdrawal.id = :id', { id })
        .getOne();

      if (!request) {
        throw new NotFoundException('Withdrawal not found');
      }

      if (
        request.status !== WithdrawalStatus.PENDING &&
        request.status !== WithdrawalStatus.APPROVED
      ) {
        throw new ConflictException(
          'This withdrawal cannot be rejected',
        );
      }

      const earnings = await earningsRepo
        .createQueryBuilder('earning')
        .setLock('pessimistic_write')
        .where('earning.withdrawalRequestId = :id', { id })
        .getMany();

      for (const earning of earnings) {
        if (
          earning.status !== EarningStatus.WITHDRAWAL_REQUESTED
        ) {
          throw new ConflictException(
            'Earning status does not match withdrawal request',
          );
        }

        earning.status = EarningStatus.APPROVED;
        earning.withdrawalRequestId = null;
      }

      await earningsRepo.save(earnings);

      request.status = WithdrawalStatus.REJECTED;
      request.reviewedBy = adminId;
      request.reviewNote = note.trim();

      return withdrawalsRepo.save(request);
    });
  }

  async assignRechargeAgent(
    id: string,
    agentId: string,
    adminId: string,
  ) {
    return this.dataSource.transaction(async (manager) => {
      const withdrawalsRepo = manager.getRepository(WithdrawalRequest);
      const agentsRepo = manager.getRepository(Agent);

      const request = await withdrawalsRepo
        .createQueryBuilder('withdrawal')
        .setLock('pessimistic_write')
        .where('withdrawal.id = :id', { id })
        .getOne();

      if (!request) {
        throw new NotFoundException('Withdrawal not found');
      }

      if (request.status !== WithdrawalStatus.APPROVED) {
        throw new ConflictException(
          'Approve the withdrawal before assigning an agent',
        );
      }

      if (request.method !== WithdrawalMethod.RECHARGE_AGENT) {
        throw new BadRequestException(
          'This request does not use a recharge agent',
        );
      }

      const agent = await agentsRepo
        .createQueryBuilder('agent')
        .setLock('pessimistic_write')
        .where('agent.id = :agentId', { agentId })
        .getOne();

      if (
        !agent ||
        agent.type !== AgentType.RECHARGE ||
        agent.status !== AgentStatus.ACTIVE
      ) {
        throw new BadRequestException(
          'An active recharge agent is required',
        );
      }

      request.assignedAgentId = agent.id;
      request.reviewedBy = adminId;

      return withdrawalsRepo.save(request);
    });
  }

  async markWithdrawalPaid(
    id: string,
    adminId: string,
    paymentReference: string,
  ) {
    const reference = paymentReference?.trim();

    if (!reference || reference.length > 255) {
      throw new BadRequestException(
        'A valid payment reference is required',
      );
    }

    return this.dataSource.transaction(async (manager) => {
      const withdrawalsRepo = manager.getRepository(WithdrawalRequest);
      const earningsRepo = manager.getRepository(HostEarning);
      const agentsRepo = manager.getRepository(Agent);

      const request = await withdrawalsRepo
        .createQueryBuilder('withdrawal')
        .setLock('pessimistic_write')
        .where('withdrawal.id = :id', { id })
        .getOne();

      if (!request) {
        throw new NotFoundException('Withdrawal not found');
      }

      if (request.status !== WithdrawalStatus.APPROVED) {
        throw new ConflictException(
          'Only approved withdrawals can be marked as paid',
        );
      }

      if (
        request.method === WithdrawalMethod.RECHARGE_AGENT &&
        !request.assignedAgentId
      ) {
        throw new BadRequestException(
          'Assign a recharge agent before recording payment',
        );
      }

      const duplicate = await withdrawalsRepo.findOne({
        where: { paymentReference: reference },
      });

      if (duplicate) {
        throw new ConflictException(
          'This payment reference has already been used',
        );
      }

      const earnings = await earningsRepo
        .createQueryBuilder('earning')
        .setLock('pessimistic_write')
        .where('earning.withdrawalRequestId = :id', { id })
        .getMany();

      if (earnings.length === 0) {
        throw new ConflictException(
          'No earnings are linked to this withdrawal',
        );
      }

      let total = 0n;

      for (const earning of earnings) {
        if (
          earning.status !== EarningStatus.WITHDRAWAL_REQUESTED
        ) {
          throw new ConflictException(
            'Earning is not reserved for this withdrawal',
          );
        }

        total += BigInt(earning.amount);
      }

      if (total !== BigInt(request.amount)) {
        throw new ConflictException(
          'Earning total does not match withdrawal amount',
        );
      }

      for (const earning of earnings) {
        earning.status = EarningStatus.PAID;
      }

      await earningsRepo.save(earnings);

      if (request.assignedAgentId) {
        const agent = await agentsRepo
          .createQueryBuilder('agent')
          .setLock('pessimistic_write')
          .where('agent.id = :agentId', {
            agentId: request.assignedAgentId,
          })
          .getOne();

        if (
          !agent ||
          agent.type !== AgentType.RECHARGE ||
          agent.status !== AgentStatus.ACTIVE
        ) {
          throw new ConflictException(
            'Assigned recharge agent is no longer active',
          );
        }

        agent.totalWithdrawn = (
          BigInt(agent.totalWithdrawn || '0') +
          BigInt(request.amount)
        ).toString();

        await agentsRepo.save(agent);
      }

      request.status = WithdrawalStatus.PAID;
      request.paymentReference = reference;
      request.reviewedBy = adminId;
      request.paidAt = new Date();

      return withdrawalsRepo.save(request);
    });
  }
      }
