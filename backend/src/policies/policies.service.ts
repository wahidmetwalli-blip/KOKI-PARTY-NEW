import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';

import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import {
  PolicyVersion,
  PolicyCategory,
  PolicyStatus,
} from './policy.entity';

@Injectable()
export class PoliciesService {
  constructor(
    @InjectRepository(PolicyVersion)
    private readonly policiesRepository: Repository<PolicyVersion>,
  ) {}

  async createDraft(
    category: PolicyCategory,
    rules: Record<string, any>,
    description?: string,
    createdBy?: string,
  ) {
    if (!Object.values(PolicyCategory).includes(category)) {
      throw new BadRequestException('Invalid policy category');
    }

    if (
      !rules ||
      typeof rules !== 'object' ||
      Array.isArray(rules)
    ) {
      throw new BadRequestException('Policy rules must be an object');
    }

    const latest = await this.policiesRepository.findOne({
      where: { category },
      order: { version: 'DESC' },
    });

    const policy = this.policiesRepository.create({
      category,
      version: (latest?.version ?? 0) + 1,
      status: PolicyStatus.DRAFT,
      rules,
      description: description || null,
      effectiveFrom: null,
      effectiveUntil: null,
      createdBy: createdBy || null,
      approvedBy: null,
      approvedAt: null,
    });

    try {
      return await this.policiesRepository.save(policy);
    } catch {
      throw new ConflictException(
        'Could not create policy version. Please try again.',
      );
    }
  }

  async getAllPolicies() {
    return this.policiesRepository.find({
      order: {
        category: 'ASC',
        version: 'DESC',
      },
    });
  }

  async getPolicyById(id: string) {
    const policy = await this.policiesRepository.findOne({
      where: { id },
    });

    if (!policy) {
      throw new NotFoundException('Policy not found');
    }

    return policy;
  }

  async getActivePolicy(category: PolicyCategory) {
    const now = new Date();

    const policy = await this.policiesRepository
      .createQueryBuilder('policy')
      .where('policy.category = :category', { category })
      .andWhere('policy.status = :status', {
        status: PolicyStatus.ACTIVE,
      })
      .andWhere(
        '(policy.effectiveFrom IS NULL OR policy.effectiveFrom <= :now)',
        { now },
      )
      .andWhere(
        '(policy.effectiveUntil IS NULL OR policy.effectiveUntil > :now)',
        { now },
      )
      .orderBy('policy.version', 'DESC')
      .getOne();

    if (!policy) {
      throw new NotFoundException('No active policy found');
    }

    return policy;
  }

  async updateDraft(
    id: string,
    rules: Record<string, any>,
    description?: string,
  ) {
    const policy = await this.getPolicyById(id);

    if (policy.status !== PolicyStatus.DRAFT) {
      throw new BadRequestException(
        'Only draft policies can be updated',
      );
    }

    if (
      !rules ||
      typeof rules !== 'object' ||
      Array.isArray(rules)
    ) {
      throw new BadRequestException('Policy rules must be an object');
    }

    policy.rules = rules;

    if (description !== undefined) {
      policy.description = description;
    }

    return this.policiesRepository.save(policy);
  }

  async approvePolicy(
    id: string,
    approvedBy: string,
    effectiveFrom: Date,
    effectiveUntil?: Date,
  ) {
    if (!approvedBy) {
      throw new BadRequestException('Approver is required');
    }

    if (
      !(effectiveFrom instanceof Date) ||
      Number.isNaN(effectiveFrom.getTime())
    ) {
      throw new BadRequestException('Invalid effective start date');
    }

    if (
      effectiveUntil &&
      (
        Number.isNaN(effectiveUntil.getTime()) ||
        effectiveUntil <= effectiveFrom
      )
    ) {
      throw new BadRequestException('Invalid effective end date');
    }

    return this.policiesRepository.manager.transaction(
      async (manager) => {
        const repository = manager.getRepository(PolicyVersion);

        const policy = await repository.findOne({
          where: { id },
          lock: { mode: 'pessimistic_write' },
        });

        if (!policy) {
          throw new NotFoundException('Policy not found');
        }

        if (policy.status !== PolicyStatus.DRAFT) {
          throw new BadRequestException(
            'Only draft policies can be approved',
          );
        }

        const activePolicies = await repository
          .createQueryBuilder('policy')
          .setLock('pessimistic_write')
          .where('policy.category = :category', {
            category: policy.category,
          })
          .andWhere('policy.status = :status', {
            status: PolicyStatus.ACTIVE,
          })
          .getMany();

        for (const active of activePolicies) {
          active.status = PolicyStatus.ARCHIVED;
          await repository.save(active);
        }

        policy.status = PolicyStatus.ACTIVE;
        policy.approvedBy = approvedBy;
        policy.approvedAt = new Date();
        policy.effectiveFrom = effectiveFrom;
        policy.effectiveUntil = effectiveUntil || null;

        return repository.save(policy);
      },
    );
  }
}
