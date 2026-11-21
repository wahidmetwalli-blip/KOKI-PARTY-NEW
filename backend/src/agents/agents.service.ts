import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
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
  ) {
    if (!userId) {
      throw new BadRequestException('User ID is required');
    }

    if (
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

    return this.agentsRepository.save(agent);
  }

  async findAll() {
    return this.agentsRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findById(id: string) {
    const agent = await this.agentsRepository.findOne({
      where: { id },
    });

    if (!agent) {
      throw new NotFoundException('Agent not found');
    }

    return agent;
  }

  async findByUser(userId: string) {
    return this.agentsRepository.find({
      where: { userId },
    });
  }

  async updateStatus(
    id: string,
    status: AgentStatus,
  ) {
    const agent = await this.findById(id);

    agent.status = status;

    return this.agentsRepository.save(agent);
  }

  async updateCommission(
    id: string,
    commissionRate: number,
  ) {
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
    const total = await this.agentsRepository.count();

    const active = await this.agentsRepository.count({
      where: { status: AgentStatus.ACTIVE },
    });

    const pending = await this.agentsRepository.count({
      where: { status: AgentStatus.PENDING },
    });

    const suspended = await this.agentsRepository.count({
      where: { status: AgentStatus.SUSPENDED },
    });

    return {
      total,
      active,
      pending,
      suspended,
    };
  }
              }
