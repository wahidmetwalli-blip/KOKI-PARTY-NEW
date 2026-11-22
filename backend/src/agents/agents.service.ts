
import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import {
  Agent,
  AgentType,
  AgentStatus,
} from './agent.entity';

import { AuditService } from '../audit/audit.service';

@Injectable()
export class AgentsService {
  constructor(
    @InjectRepository(Agent)
    private readonly agentsRepository: Repository<Agent>,
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
      throw new ConflictException(
        'This user is already registered as this agent type',
      );
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
        (agent) => agent.status === AgentStatus.ACTIVE,
      ).length,
      pending: agents.filter(
        (agent) => agent.status === AgentStatus.PENDING,
      ).length,
      suspended: agents.filter(
        (agent) => agent.status === AgentStatus.SUSPENDED,
      ).length,
      hosts: agents.filter(
        (agent) => agent.type === AgentType.HOST,
      ).length,
      rechargeAgents: agents.filter(
        (agent) => agent.type === AgentType.RECHARGE,
      ).length,
    };
  }
}
