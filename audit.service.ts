
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuditLog } from './audit.entity';

@Injectable()
export class AuditService {
  constructor(
    @InjectRepository(AuditLog)
    private readonly auditRepository: Repository<AuditLog>,
  ) {}

  async record(
    actorUserId: string | null,
    action: string,
    entityType: string,
    entityId: string,
    metadata: Record<string, unknown> | null = null,
  ) {
    const log = this.auditRepository.create({
      actorUserId,
      action,
      entityType,
      entityId,
      metadata,
    });

    return this.auditRepository.save(log);
  }

  async listRecent(limit = 100) {
    return this.auditRepository.find({
      order: { createdAt: 'DESC' },
      take: Math.min(Math.max(limit, 1), 500),
    });
  }
}
