import { SetMetadata } from '@nestjs/common';
import { Permission } from './permissions.enum';
import { REQUIRED_PERMISSIONS } from './permissions.guard';

export const RequirePermissions = (
  ...permissions: Permission[]
) => SetMetadata(REQUIRED_PERMISSIONS, permissions);
