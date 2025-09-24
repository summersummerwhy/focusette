import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient
    implements OnModuleInit, OnModuleDestroy {
    async onModuleInit() {
        await this.$connect(); // 앱 시작 시 DB 연결
    }

    async onModuleDestroy() {
        await this.$disconnect(); // 앱 종료 시 연결 해제
    }
}
