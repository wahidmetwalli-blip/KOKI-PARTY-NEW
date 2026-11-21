import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Req,
  UseGuards,
  ParseUUIDPipe,
  ForbiddenException,
  Injectable,
  CanActivate,
  ExecutionContext,
} from '@nestjs/common';

import { Request } from 'express';

import {
  IsEnum,
  IsObject,
  IsOptional,
  IsString,
  MaxLength,
  IsDateString,
} from 'class-validator';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';

import {
  PoliciesService,
} from './policies.service';

import {
  PolicyCategory,
} from './policy.entity';

class OwnerOnlyGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || user.role !== 'OWNER') {
      throw new ForbiddenException(
        'Only the application owner can manage policies',
      );
    }

    return true;
  }
}

class CreatePolicyDto {
  @IsEnum(PolicyCategory)
  category: PolicyCategory;

  @IsObject()
  rules: Record<string, any>;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;
}

class UpdatePolicyDto {
  @IsObject()
  rules: Record<string, any>;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;
}

class ApprovePolicyDto {
  @IsDateString()
  effectiveFrom: string;

  @IsOptional()
  @IsDateString()
  effectiveUntil?: string;
}

interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    role: string;
    permissions: string[];
  };
}

@Controller('policies')
@UseGuards(JwtAuthGuard, OwnerOnlyGuard)
export class PoliciesController {
  constructor(
    private readonly policiesService: PoliciesService,
  ) {}

  @Get()
  getAllPolicies() {
    return this.policiesService.getAllPolicies();
  }

  @Get(':id')
  getPolicy(
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.policiesService.getPolicyById(id);
  }

  @Get('active/:category')
  getActivePolicy(
    @Param('category') category: PolicyCategory,
  ) {
    return this.policiesService.getActivePolicy(category);
  }

  @Post()
  createDraft(
    @Req() req: AuthenticatedRequest,
    @Body() dto: CreatePolicyDto,
  ) {
    return this.policiesService.createDraft(
      dto.category,
      dto.rules,
      dto.description,
      req.user.id,
    );
  }

  @Patch(':id')
  updateDraft(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePolicyDto,
  ) {
    return this.policiesService.updateDraft(
      id,
      dto.rules,
      dto.description,
    );
  }

  @Post(':id/approve')
  approvePolicy(
    @Req() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ApprovePolicyDto,
  ) {
    const effectiveFrom = new Date(dto.effectiveFrom);

    const effectiveUntil = dto.effectiveUntil
      ? new Date(dto.effectiveUntil)
      : undefined;

    return this.policiesService.approvePolicy(
      id,
      req.user.id,
      effectiveFrom,
      effectiveUntil,
    );
  }
}
