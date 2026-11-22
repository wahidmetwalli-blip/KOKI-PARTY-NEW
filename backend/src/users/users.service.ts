import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
import { UserRole } from '../auth/roles.enum';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async findByEmail(email: string): Promise<User | null> {
    return this.usersRepository.findOne({
      where: { email: email.toLowerCase() },
    });
  }

  async findByPhone(phone: string): Promise<User | null> {
    return this.usersRepository.findOne({
      where: { phone },
    });
  }

  async findById(id: string): Promise<User | null> {
    return this.usersRepository.findOne({
      where: { id },
    });
  }

  async countUsers(): Promise<number> {
    return this.usersRepository.count();
  }

  async countOwners(): Promise<number> {
    return this.usersRepository.count({
      where: { role: UserRole.OWNER },
    });
  }

  async createOwner(
    email: string | null,
    phone: string | null,
    passwordHash: string,
  ): Promise<User> {
    const owner = this.usersRepository.create({
      email: email ? email.toLowerCase() : null,
      phone,
      passwordHash,
      role: UserRole.OWNER,
      permissions: [],
      isActive: true,
    });

    return this.usersRepository.save(owner);
  }
}
