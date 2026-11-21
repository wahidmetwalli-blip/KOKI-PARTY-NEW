
import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  UseGuards,
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  ParseIntPipe,
} from '@nestjs/common';

import {
  IsInt,
  IsString,
  IsOptional,
  IsBoolean,
  Matches,
  Min,
  Max,
} from 'class-validator';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UserRole } from '../auth/roles.enum';
import { HostLevelService } from './host-level.service';

@Injectable()
class OwnerOnlyGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || user.role !== UserRole.OWNER) {
      throw new ForbiddenException('OWNER access required');
    }

    return true;
  }
}

class CreateHostLevelDto {
  @IsInt()
  @Min(1)
  @Max(12)
  level: number;

  @IsString()
  @Matches(/^\d+$/)
  requiredDiamonds: string;

  @IsString()
  @Matches(/^\d+(\.\d{1,2})?$/)
  diamondRate: string;

  @IsString()
  @Matches(/^\d+$/)
  hostSalaryUsdCents: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  vipLevel?: number;

  @IsOptional()
  @IsBoolean()
  systemDisplay?: boolean;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

class UpdateHostLevelDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(12)
  level?: number;

  @IsOptional()
  @IsString()
  @Matches(/^\d+$/)
  requiredDiamonds?: string;

  @IsOptional()
  @IsString()
  @Matches(/^\d+(\.\d{1,2})?$/)
  diamondRate?: string;

  @IsOptional()
  @IsString()
  @Matches(/^\d+$/)
  hostSalaryUsdCents?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  vipLevel?: number;

  @IsOptional()
  @IsBoolean()
  systemDisplay?: boolean;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

@Controller('host-levels')
@UseGuards(JwtAuthGuard, OwnerOnlyGuard)
export class HostLevelController {
  constructor(
    private readonly hostLevelService: HostLevelService,
  ) {}

  @Get()
  getAllLevels() {
    return this.hostLevelService.getAllLevels();
  }

  @Get('active')
  getActiveLevels() {
    return this.hostLevelService.getActiveLevels();
  }

  @Get(':level')
  getLevelByNumber(
    @Param('level', ParseIntPipe) level: number,
  ) {
    return this.hostLevelService.getLevelByNumber(level);
  }

  @Post()
  createLevel(
    @Body() data: CreateHostLevelDto,
  ) {
    return this.hostLevelService.createLevel(data);
  }

  @Patch(':level')
  updateLevel(
    @Param('level', ParseIntPipe) level: number,
    @Body() data: UpdateHostLevelDto,
  ) {
    return this.hostLevelService.updateLevel(level, data);
  }

  @Delete(':level')
  deactivateLevel(
    @Param('level', ParseIntPipe) level: number,
  ) {
    return this.hostLevelService.deactivateLevel(level);
  }
}
