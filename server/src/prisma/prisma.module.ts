import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global() // 전역 모듈로 등록 (어디서든 주입 가능)
@Module({
    providers: [PrismaService],
    exports: [PrismaService],
})
export class PrismaModule { }