import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Permission } from './permissions.enum';

export const REQUIRED_PERMISSIONS = 'required_permissions';

@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<Permission[]>(
      REQUIRED_PERMISSIONS,
      [context.getHandler(), context.getClass()],
    );

    if (!required || required.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('Access denied');
    }

    if (user.role === 'OWNER') {
      return true;
    }

    const userPermissions: string[] = user.permissions || [];

    const allowed = required.every((permission) =>
      userPermissions.includes(permission),
    );

    if (!allowed) {
      throw new ForbiddenException('You do not have permission');
    }

    return true;
  }
  }
