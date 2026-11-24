import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';

import {
  Agent,
  AgentType,
  AgentStatus,
} from './agent.entity';

import { AgentCommission } from './agent-commission.entity';

import {
  AgentPayout,
  AgentPayoutStatus,
} from './agent-payout.entity';

import { AuditService } from '../audit/audit.service';
import { AuditLog } from '../audit/audit.entity';

@Injectable()
export class AgentsService {
  constructor(
    @InjectRepository(Agent)
    private readonly agentsRepository: Repository<Agent>,

    @InjectRepository(AgentCommission)
    private readonly commissionsRepository: Repository<AgentCommission>,

    @InjectRepository(AgentPayout)
    private readonly payoutsRepository: Repository<AgentPayout>,

    private readonly dataSource: DataSource,
    private readonly auditService: AuditService,
  ) {}

  async create(
    userId: string,
    type: AgentType,
    commissionRate = 0,
    adminId?: string,
  ): Promise<Agent> {
    if (!userId) {
      throw new BadRequestException('User ID is required');
    }

    if (
      !Number.isFinite(commissionRate) ||
      commissionRate < 0 ||
      commissionRate > 100
    ) {
      throw new BadRequestException('Invalid commission rate');
    }

    const existing = await this.agentsRepository.findOne({
      where: { userId, type },
    });

    if (existing) {
      throw new ConflictException('Agent already exists');
    }

    const agent = this.agentsRepository.create({
      userId,
      type,
      status: AgentStatus.PENDING,
      commissionRate,
    });

    const saved = await this.agentsRepository.save(agent);

    await this.auditService.record(
      adminId || null,
      'AGENT_CREATED',
      'agent',
      saved.id,
      { userId, type, commissionRate },
    );

    return saved;
  }

  async findAll(): Promise<Agent[]> {
    return this.agentsRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findById(id: string): Promise<Agent> {
    const agent = await this.agentsRepository.findOne({
      where: { id },
    });

    if (!agent) {
      throw new NotFoundException('Agent not found');
    }

    return agent;
  }

  async findByUser(
    userId: string,
    type?: AgentType,
  ): Promise<Agent[]> {
    return this.agentsRepository.find({
      where: type ? { userId, type } : { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async updateStatus(
    id: string,
    status: AgentStatus,
    adminId?: string,
  ): Promise<Agent> {
    if (!Object.values(AgentStatus).includes(status)) {
      throw new BadRequestException('Invalid agent status');
    }

    const agent = await this.findById(id);
    const previousStatus = agent.status;

    agent.status = status;

    const saved = await this.agentsRepository.save(agent);

    await this.auditService.record(
      adminId || null,
      'AGENT_STATUS_UPDATED',
      'agent',
      id,
      { previousStatus, newStatus: status },
    );

    return saved;
  }

  async updateCommission(
    id: string,
    commissionRate: number,
    adminId?: string,
  ): Promise<Agent> {
    if (
      !Number.isFinite(commissionRate) ||
      commissionRate < 0 ||
      commissionRate > 100
    ) {
      throw new BadRequestException('Invalid commission rate');
    }

    const agent = await this.findById(id);
    const previousRate = agent.commissionRate;

    agent.commissionRate = commissionRate;

    const saved = await this.agentsRepository.save(agent);

    await this.auditService.record(
      adminId || null,
      'AGENT_COMMISSION_UPDATED',
      'agent',
      id,
      { previousRate, newRate: commissionRate },
    );

    return saved;
  }

  async getStatistics() {
    const agents = await this.agentsRepository.find();

    return {
      total: agents.length,

      active: agents.filter(
        a => a.status === AgentStatus.ACTIVE,
      ).length,

      pending: agents.filter(
        a => a.status === AgentStatus.PENDING,
      ).length,

      suspended: agents.filter(
        a => a.status === AgentStatus.SUSPENDED,
      ).length,

      hosts: agents.filter(
        a => a.type === AgentType.HOST,
      ).length,

      rechargeAgents: agents.filter(
        a => a.type === AgentType.RECHARGE,
      ).length,
    };
  }

  async getCommissionStatistics() {
    const commissions = await this.commissionsRepository.find();

    let totalBaseAmount = 0n;
    let totalCommissionAmount = 0n;

    for (const commission of commissions) {
      totalBaseAmount += BigInt(commission.baseAmount);

      totalCommissionAmount += BigInt(
        commission.commissionAmount,
      );
    }

    return {
      totalCommissions: commissions.length,
      totalBaseAmount: totalBaseAmount.toString(),
      totalCommissionAmount: totalCommissionAmount.toString(),
      currency: 'USD',
      unit: 'cents',
    };
  }

  async getAgentCommissions(agentId: string) {
    await this.findById(agentId);

    const commissions = await this.commissionsRepository.find({
      where: { agentId },
      order: { createdAt: 'DESC' },
      take: 200,
    });

    let totalBaseAmount = 0n;
    let totalCommissionAmount = 0n;

    for (const commission of commissions) {
      totalBaseAmount += BigInt(commission.baseAmount);

      totalCommissionAmount += BigInt(
        commission.commissionAmount,
      );
    }

    return {
      agentId,
      count: commissions.length,
      totalBaseAmount: totalBaseAmount.toString(),
      totalCommissionAmount: totalCommissionAmount.toString(),
      currency: 'USD',
      unit: 'cents',
      commissions,
    };
  }

  async getAgentPayouts(agentId: string) {
    await this.findById(agentId);

    return this.payoutsRepository.find({
      where: { agentId },
      order: { createdAt: 'DESC' },
      take: 200,
    });
  }

  async getAgentFinancialSummary(agentId: string) {
    await this.findById(agentId);

    const commissions = await this.commissionsRepository.find({
      where: { agentId },
    });

    const payouts = await this.payoutsRepository.find({
      where: { agentId },
    });

    let totalCommission = 0n;

    for (const item of commissions) {
      totalCommission += BigInt(item.commissionAmount);
    }

    let pending = 0n;
    let approved = 0n;
    let paid = 0n;
    let reserved = 0n;

    for (const payout of payouts) {
      const amount = BigInt(payout.amount);

      if (payout.status === AgentPayoutStatus.PENDING) {
        pending += amount;
        reserved += amount;
      } else if (
        payout.status === AgentPayoutStatus.APPROVED
      ) {
        approved += amount;
        reserved += amount;
      } else if (payout.status === AgentPayoutStatus.PAID) {
        paid += amount;
      }
    }

    return {
      agentId,
      currency: 'USD',
      unit: 'cents',
      totalCommission: totalCommission.toString(),
      pendingPayouts: pending.toString(),
      approvedPayouts: approved.toString(),
      paidPayouts: paid.toString(),

      availableBalance: (
        totalCommission - reserved - paid
      ).toString(),
    };
  }

  // طلب الوكيل سحب أرباحه
  async requestAgentPayout(
    agentId: string,
    amount: string,
  ) {
    if (
      typeof amount !== 'string' ||
      !/^[1-9]\d*$/.test(amount)
    ) {
      throw new BadRequestException(
        'Amount must be positive USD cents',
      );
    }

    return this.dataSource.transaction(async manager => {
      const agentsRepo = manager.getRepository(Agent);

      const commissionsRepo =
        manager.getRepository(AgentCommission);

      const payoutsRepo =
        manager.getRepository(AgentPayout);

      const auditsRepo =
        manager.getRepository(AuditLog);

      const agent = await agentsRepo.findOne({
        where: { id: agentId },
        lock: { mode: 'pessimistic_write' },
      });

      if (!agent || agent.type !== AgentType.RECHARGE) {
        throw new NotFoundException(
          'Recharge agent not found',
        );
      }

      if (agent.status !== AgentStatus.ACTIVE) {
        throw new BadRequestException(
          'Agent is not active',
        );
      }

      const commissions = await commissionsRepo.find({
        where: { agentId },
      });

      const payouts = await payoutsRepo.find({
        where: { agentId },
      });

      let earned = 0n;

      for (const item of commissions) {
        earned += BigInt(item.commissionAmount);
      }

      let reserved = 0n;

      for (const payout of payouts) {
        if (
          payout.status === AgentPayoutStatus.PENDING ||
          payout.status === AgentPayoutStatus.APPROVED ||
          payout.status === AgentPayoutStatus.PAID
        ) {
          reserved += BigInt(payout.amount);
        }
      }

      const available = earned - reserved;
      const requested = BigInt(amount);

      if (requested > available) {
        throw new BadRequestException(
          'Insufficient available commission balance',
        );
      }

      const payout = payoutsRepo.create({
        agentId,
        amount,
        currency: 'USD',
        status: AgentPayoutStatus.PENDING,
      });

      const saved = await payoutsRepo.save(payout);

      await auditsRepo.save(
        auditsRepo.create({
          actorUserId: agent.userId,
          action: 'AGENT_PAYOUT_REQUESTED',
          entityType: 'agent_payout',
          entityId: saved.id,
          metadata: {
            agentId,
            amount,
            currency: 'USD',
          },
        }),
      );

      return saved;
    });
  }

  // مراجعة طلب السحب بالموافقة أو الرفض
  async reviewAgentPayout(
    payoutId: string,
    status:
      | AgentPayoutStatus.APPROVED
      | AgentPayoutStatus.REJECTED,
    adminId: string,
    note?: string,
  ) {
    if (
      status !== AgentPayoutStatus.APPROVED &&
      status !== AgentPayoutStatus.REJECTED
    ) {
      throw new BadRequestException(
        'Invalid payout review status',
      );
    }

    return this.dataSource.transaction(async manager => {
      const payoutsRepo =
        manager.getRepository(AgentPayout);

      const auditsRepo =
        manager.getRepository(AuditLog);

      const payout = await payoutsRepo.findOne({
        where: { id: payoutId },
        lock: { mode: 'pessimistic_write' },
      });

      if (!payout) {
        throw new NotFoundException('Payout not found');
      }

      if (payout.status !== AgentPayoutStatus.PENDING) {
        throw new ConflictException(
          'Payout is not pending',
        );
      }

      payout.status = status;
      payout.reviewedBy = adminId;
      payout.reviewNote = note?.trim() || null;

      const saved = await payoutsRepo.save(payout);

      await auditsRepo.save(
        auditsRepo.create({
          actorUserId: adminId,
          action: `AGENT_PAYOUT_${status}`,
          entityType: 'agent_payout',
          entityId: payoutId,
          metadata: {
            agentId: payout.agentId,
            amount: payout.amount,
            note: note?.trim() || null,
          },
        }),
      );

      return saved;
    });
  }

  // تأكيد دفع أرباح الوكيل
  async markAgentPayoutPaid(
    payoutId: string,
    paymentReference: string,
    adminId: string,
  ) {
    if (
      typeof paymentReference !== 'string' ||
      !paymentReference.trim() ||
      paymentReference.trim().length > 255
    ) {
      throw new BadRequestException(
        'Valid payment reference is required',
      );
    }

    return this.dataSource.transaction(async manager => {
      const payoutsRepo =
        manager.getRepository(AgentPayout);

      const auditsRepo =
        manager.getRepository(AuditLog);

      const payout = await payoutsRepo.findOne({
        where: { id: payoutId },
        lock: { mode: 'pessimistic_write' },
      });

      if (!payout) {
        throw new NotFoundException('Payout not found');
      }

      if (payout.status !== AgentPayoutStatus.APPROVED) {
        throw new ConflictException(
          'Only approved payouts can be marked paid',
        );
      }

      payout.status = AgentPayoutStatus.PAID;
      payout.paymentReference = paymentReference.trim();
      payout.reviewedBy = adminId;
      payout.paidAt = new Date();

      const saved = await payoutsRepo.save(payout);

      await auditsRepo.save(
        auditsRepo.create({
          actorUserId: adminId,
          action: 'AGENT_PAYOUT_PAID',
          entityType: 'agent_payout',
          entityId: payoutId,
          metadata: {
            agentId: payout.agentId,
            amount: payout.amount,
            paymentReference: payout.paymentReference,
          },
        }),
      );

      return saved;
    });
  }
    }
