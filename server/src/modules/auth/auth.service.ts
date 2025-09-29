import { Injectable, UnauthorizedException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { v4 as uuid } from 'uuid';
import axios from 'axios';

@Injectable()
export class AuthService {
    constructor(private prisma: PrismaService) { }
    // OAuth 프로필 가져오기
    private async fetchProfile(provider: 'google' | 'kakao' | 'naver', accessToken: string) {
        if (provider === 'google') {
            const res = await axios.get('https://www.googleapis.com/oauth2/v2/userinfo', {
                headers: { Authorization: `Bearer ${accessToken}` },
            });
            return { id: res.data.id, email: res.data.email, name: res.data.name };
        } else if (provider === 'kakao') {
            const res = await axios.get('https://kapi.kakao.com/v2/user/me', {
                headers: { Authorization: `Bearer ${accessToken}` },
            });
            return {
                id: res.data.id,
                email: res.data.kakao_account?.email,
                name: res.data.properties?.nickname,
            };
        } else if (provider === 'naver') {
            const res = await axios.get('https://openapi.naver.com/v1/nid/me', {
                headers: { Authorization: `Bearer ${accessToken}` },
            });
            return {
                id: res.data.response.id,
                email: res.data.response.email,
                name: res.data.response.name,
            };
        }
        throw new UnauthorizedException('Unsupported provider');
    }

    // 로그인만
    async login(provider: 'google' | 'kakao' | 'naver', accessToken: string) {
        const profile = await this.fetchProfile(provider, accessToken);

        const user = await this.prisma.user.findUnique({
            where: { provider_providerId: { provider, providerId: String(profile.id) } },
        });

        if (!user) {
            // 계정 없음 → 회원가입 안내
            throw new NotFoundException({
                message: 'No account found. Please sign up first.',
                provider,
                providerId: profile.id,
                email: profile.email,
            });
        }

        return this.createSession(user.id);
    }

    // 회원가입
    async signup(provider: 'google' | 'kakao' | 'naver', accessToken: string) {
        const profile = await this.fetchProfile(provider, accessToken);

        let user = await this.prisma.user.findUnique({
            where: { provider_providerId: { provider, providerId: String(profile.id) } },
        });

        if (user) {
            // 이미 가입된 계정
            return this.createSession(user.id);
        }

        user = await this.prisma.user.create({
            data: {
                provider,
                providerId: String(profile.id),
                email: profile.email,
                nickname: profile.name,
                character: 'default',
            },
        });

        return this.createSession(user.id);
    }

    // 세션 생성 공통 함수
    private async createSession(userId: number) {
        const newAccessToken = uuid();
        const refreshToken = uuid();
        const expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24 * 7); // 7일

        await this.prisma.authSession.create({
            data: { userId, accessToken: newAccessToken, refreshToken, expiresAt },
        });

        return { accessToken: newAccessToken, refreshToken, userId };
    }

    async logout(accessToken: string) {
        await this.prisma.authSession.delete({ where: { accessToken } });
        return { message: 'Logged out' };
    }



}
