
import {
  Controller,
  Get,
  Query,
  UseGuards,
  ParseIntPipe,
  DefaultValuePipe,
} from '@nestjs/common';

import { AuditService } from './audit.service';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PermissionsGuard } from '../auth/permissions.guard';
import { RequirePermissions } from '../auth/permissions.decorator';
import { Permission } from '../auth/permissions.enum';

@Controller('audit')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class AuditController {
  constructor(
    private readonly auditService: AuditService,
  ) {}

  @Get()
  @RequirePermissions(Permission.AUDIT_LOG_VIEW)
  listRecent(
    @Query('limit', new DefaultValuePipe(100), ParseIntPipe)
    limit: number,
  ) {
    return this.auditService.listRecent(limit);
  }
}
