
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

@Injectable()
export class AgentsService {
  constructor(
    @InjectRepository(Agent)
    private readonly agentsRepository: Repository<Agent>,
  ) {}

  async create(
    userId: string,
    type: AgentType,
    commissionRate = 0,
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

    return this.agentsRepository.save(agent);
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
  ): Promise<Agent> {
    if (!Object.values(AgentStatus).includes(status)) {
      throw new BadRequestException('Invalid agent status');
    }

    const agent = await this.findById(id);
    agent.status = status;

    return this.agentsRepository.save(agent);
  }

  async updateCommission(
    id: string,
    commissionRate: number,
  ): Promise<Agent> {
    if (
      !Number.isFinite(commissionRate) ||
      commissionRate < 0 ||
      commissionRate > 100
    ) {
      throw new BadRequestException('Invalid commission rate');
    }

    const agent = await this.findById(id);
    agent.commissionRate = commissionRate;

    return this.agentsRepository.save(agent);
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
