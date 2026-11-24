
import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';

import { DataSource, QueryFailedError } from 'typeorm';
import { Gift } from '../gifts/gift.entity';
import { HostDiamondLedger } from './host-diamond-ledger.entity';
import { UsersService } from '../users/users.service';
import { User } from '../users/user.entity';

import { Room } from '../rooms/room.entity';
import { RoomSeat } from '../rooms/room-seat.entity';

import {
  Wallet,
  WalletTransaction,
  WalletTransactionType,
} from '../wallet/wallet.entity';

import { PoliciesService } from '../policies/policies.service';
import { PolicyCategory } from '../policies/policy.entity';

@Injectable()
export class HostDiamondsService {
  constructor(
    private readonly dataSource: DataSource,
    private readonly usersService: UsersService,
    private readonly policiesService: PoliciesService,
  ) {}

  async getGiftDiamondConversion() {
    const policy = await this.policiesService.getActivePolicy(
      PolicyCategory.COMMISSIONS,
    );

    const rate = String(
      policy.rules?.giftDiamondConversion?.diamondsPerCoin ?? '',
    );

    if (!/^[1-9]\d*$/.test(rate)) {
      throw new BadRequestException(
        'Gift diamond conversion is not configured correctly',
      );
    }

    return {
      policyId: policy.id,
      policyVersion: policy.version,
      diamondsPerCoin: rate,
    };
  }

  async sendGift(
    senderUserId: string,
    hostUserId: string,
    giftId: string,
    reference: string,
    roomId: string,
    seatNumber: number,
    description?: string,
  ) {
    if (
      !senderUserId ||
      !hostUserId ||
      senderUserId === hostUserId
    ) {
      throw new BadRequestException(
        'Invalid sender or host account',
      );
    }

    if (
      typeof giftId !== 'string' ||
      !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
        giftId,
      )
    ) {
      throw new BadRequestException(
        'A valid gift ID is required',
      );
    }

    if (
      typeof roomId !== 'string' ||
      !roomId.trim()
    ) {
      throw new BadRequestException(
        'A valid room ID is required',
      );
    }

    if (
      !Number.isInteger(seatNumber) ||
      seatNumber < 1 ||
      seatNumber > 20
    ) {
      throw new BadRequestException(
        'A valid occupied seat number is required',
      );
    }

    if (
      typeof reference !== 'string' ||
      !reference.trim() ||
      reference.trim().length > 120
    ) {
      throw new BadRequestException(
        'A valid unique gift reference is required',
      );
    }

    const normalizedReference = reference.trim();
    const normalizedRoomId = roomId.trim();
    const debitKey = `gift:${normalizedReference}:debit`;

    try {
      return await this.dataSource.transaction(async (manager) => {
        const walletRepository = manager.getRepository(Wallet);
        const transactionRepository =
          manager.getRepository(WalletTransaction);
        const ledgerRepository =
          manager.getRepository(HostDiamondLedger);
        const roomRepository = manager.getRepository(Room);
        const seatRepository = manager.getRepository(RoomSeat);
        const userRepository = manager.getRepository(User);
        const giftRepository = manager.getRepository(Gift);

        /*
         * سعر الهدية يأتي من قاعدة البيانات فقط.
         * لا نستخدم أي سعر مرسل من تطبيق المستخدم.
         */
        const gift = await giftRepository.findOne({
          where: {
            id: giftId,
            isActive: true,
          },
        });

        if (!gift) {
          throw new NotFoundException(
            'Gift not found or inactive',
          );
        }

        const coinAmount = BigInt(gift.coinPrice);

        if (coinAmount <= 0n) {
          throw new BadRequestException(
            'Gift price is invalid',
          );
        }

        /*
         * منع إعادة تنفيذ نفس الهدية بنفس المرجع.
         */
        const existingLedger = await ledgerRepository.findOne({
          where: {
            reference: normalizedReference,
          },
        });

        const existingTransaction =
          await transactionRepository.findOne({
            where: {
              idempotencyKey: debitKey,
            },
          });

        const expectedTransactionDescription =
          `giftId:${gift.id};`;

        const expectedLedgerDescription =
          `giftId:${gift.id};`;

        if (existingLedger && existingTransaction) {
          if (
            existingLedger.hostUserId !== hostUserId ||
            existingTransaction.amount !== coinAmount.toString() ||
            existingTransaction.type !== WalletTransactionType.DEBIT ||
            existingTransaction.reference !==
              `gift:${normalizedReference}` ||
            !existingTransaction.description?.startsWith(
              expectedTransactionDescription,
            ) ||
            !existingLedger.description?.startsWith(
              expectedLedgerDescription,
            )
          ) {
            throw new ConflictException(
              'Gift reference was already used with different data',
            );
          }

          return {
            alreadyProcessed: true,
            walletTransaction: existingTransaction,
            diamondRecord: existingLedger,
            coinsDebited: existingTransaction.amount,
            diamondsEarned: existingLedger.amount,
          };
        }

        if (existingLedger || existingTransaction) {
          throw new ConflictException(
            'Incomplete previous gift transaction',
          );
        }

        /*
         * التحقق من الغرفة النشطة وقفلها أثناء العملية.
         */
        const room = await roomRepository.findOne({
          where: {
            id: normalizedRoomId,
            isActive: true,
          },
          lock: {
            mode: 'pessimistic_write',
          },
        });

        if (!room) {
          throw new NotFoundException(
            'الغرفة غير موجودة أو غير نشطة',
          );
        }

        if (seatNumber > room.maxSeats) {
          throw new BadRequestException(
            'رقم المقعد خارج مقاعد الغرفة الحالية',
          );
        }

        /*
         * التحقق من أن المضيف ما زال جالساً في المقعد.
         */
        const selectedSeat = await seatRepository
          .createQueryBuilder('seat')
          .setLock('pessimistic_write')
          .where('seat.roomId = :roomId', {
            roomId: normalizedRoomId,
          })
          .andWhere('seat.seatNumber = :seatNumber', {
            seatNumber,
          })
          .getOne();

        if (!selectedSeat) {
          throw new NotFoundException(
            'المقعد المختار غير موجود في الغرفة',
          );
        }

        if (
          !selectedSeat.userId ||
          selectedSeat.userId !== hostUserId
        ) {
          throw new ConflictException(
            'المضيف المختار لم يعد جالساً على المقعد المحدد. لم يتم خصم أي عملات',
          );
        }

        /*
         * التحقق من حساب المرسل والمضيف.
         */
        const sender = await userRepository.findOne({
          where: {
            id: senderUserId,
            isActive: true,
          },
        });

        if (!sender) {
          throw new NotFoundException(
            'Active sender not found',
          );
        }

        const host = await userRepository.findOne({
          where: {
            id: hostUserId,
            isActive: true,
          },
        });

        if (!host) {
          throw new NotFoundException(
            'Active host not found',
          );
        }

        /*
         * قراءة سياسة تحويل العملات إلى ألماس.
         */
        const conversion =
          await this.getGiftDiamondConversion();

        const diamondsPerCoin = BigInt(
          conversion.diamondsPerCoin,
        );

        const diamondAmount = (
          coinAmount * diamondsPerCoin
        ).toString();

        /*
         * قفل محفظة المرسل قبل فحص الرصيد.
         */
        const wallet = await walletRepository
          .createQueryBuilder('wallet')
          .setLock('pessimistic_write')
          .where('wallet.userId = :userId', {
            userId: senderUserId,
          })
          .getOne();

        if (!wallet) {
          throw new NotFoundException(
            'Sender wallet not found',
          );
        }

        const balanceBefore = BigInt(wallet.coinBalance);

        if (balanceBefore < coinAmount) {
          throw new BadRequestException(
            'Insufficient coin balance',
          );
        }

        const balanceAfter = balanceBefore - coinAmount;

        wallet.coinBalance = balanceAfter.toString();

        await walletRepository.save(wallet);

        /*
         * تسجيل خصم العملات.
         */
        const transactionDescription =
          `giftId:${gift.id}; ` +
          `Gift ${gift.name}; ` +
          (description?.trim() || 'Gift sent');

        const walletTransaction =
          transactionRepository.create({
            walletId: wallet.id,
            type: WalletTransactionType.DEBIT,
            amount: coinAmount.toString(),
            balanceBefore: balanceBefore.toString(),
            balanceAfter: balanceAfter.toString(),
            reference: `gift:${normalizedReference}`,
            idempotencyKey: debitKey,
            description: transactionDescription,
          });

        const savedTransaction =
          await transactionRepository.save(
            walletTransaction,
          );

        /*
         * تسجيل الألماس للمضيف الموجود على المقعد.
         */
        const ledgerDescription =
          `giftId:${gift.id}; ` +
          `Gift ${gift.name}; ` +
          `${coinAmount.toString()} coins; ` +
          `${conversion.diamondsPerCoin} diamonds per coin; ` +
          `room ${normalizedRoomId}; ` +
          `seat ${seatNumber}; ` +
          `policy version ${conversion.policyVersion}`;

        const diamondRecord = ledgerRepository.create({
          hostUserId,
          amount: diamondAmount,
          source: 'GIFT',
          reference: normalizedReference,
          description: ledgerDescription,
        });

        const savedDiamondRecord =
          await ledgerRepository.save(diamondRecord);

        return {
          alreadyProcessed: false,
          walletTransaction: savedTransaction,
          diamondRecord: savedDiamondRecord,
          gift: {
            id: gift.id,
            name: gift.name,
            coinPrice: coinAmount.toString(),
          },
          coinsDebited: coinAmount.toString(),
          diamondsEarned: diamondAmount,
          recipient: {
            hostUserId,
            roomId: normalizedRoomId,
            seatNumber,
          },
          conversion: {
            diamondsPerCoin: conversion.diamondsPerCoin,
            policyVersion: conversion.policyVersion,
          },
        };
      });
    } catch (error) {
      if (
        error instanceof QueryFailedError &&
        (error as any).driverError?.code === '23505'
      ) {
        throw new ConflictException(
          'This gift was already processed',
        );
      }

      throw error;
    }
  }

  async recordReceivedDiamonds(
    hostUserId: string,
    amount: string,
    reference: string,
    source = 'GIFT',
    description?: string,
  ) {
    if (
      typeof amount !== 'string' ||
      !/^[1-9]\d*$/.test(amount)
    ) {
      throw new BadRequestException(
        'Diamond amount must be a positive integer',
      );
    }

    if (
      !hostUserId ||
      typeof reference !== 'string' ||
      !reference.trim() ||
      reference.trim().length > 150
    ) {
      throw new BadRequestException(
        'Valid host ID and unique reference are required',
      );
    }

    if (
      typeof source !== 'string' ||
      !source.trim() ||
      source.trim().length > 50
    ) {
      throw new BadRequestException(
        'Invalid source',
      );
    }

    const host = await this.usersService.findById(hostUserId);

    if (!host || !host.isActive) {
      throw new NotFoundException(
        'Active host account not found',
      );
    }

    const repository = this.dataSource.getRepository(
      HostDiamondLedger,
    );

    const normalizedReference = reference.trim();

    const existing = await repository.findOne({
      where: {
        reference: normalizedReference,
      },
    });

    if (existing) {
      throw new ConflictException(
        'This diamond transaction was already recorded',
      );
    }

    const record = repository.create({
      hostUserId,
      amount,
      reference: normalizedReference,
      source: source.trim(),
      description: description?.trim() || null,
    });

    try {
      return await repository.save(record);
    } catch (error) {
      if (
        error instanceof QueryFailedError &&
        (error as any).driverError?.code === '23505'
      ) {
        throw new ConflictException(
          'This diamond transaction was already recorded',
        );
      }

      throw error;
    }
  }

  async getHostDiamondHistory(hostUserId: string) {
    return this.dataSource
      .getRepository(HostDiamondLedger)
      .find({
        where: {
          hostUserId,
        },
        order: {
          createdAt: 'DESC',
        },
        take: 100,
      });
  }

  async getHostDiamondTotal(hostUserId: string) {
    const result = await this.dataSource
      .getRepository(HostDiamondLedger)
      .createQueryBuilder('ledger')
      .select(
        'COALESCE(SUM(ledger.amount), 0)',
        'total',
      )
      .where('ledger.hostUserId = :hostUserId', {
        hostUserId,
      })
      .getRawOne();

    return {
      hostUserId,
      totalDiamonds: String(result?.total ?? '0'),
    };
  }
    }
    
