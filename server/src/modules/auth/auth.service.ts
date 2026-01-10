import { Injectable, UnauthorizedException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt'
import axios from 'axios';

@Injectable()
export class AuthService {
    constructor(
        private prisma: PrismaService,
        private jwtService: JwtService,
    ) { }

    // JWT 발급
    private async createTokens(userId: string) {
        const payload = { sub: userId };

        const accessToken = this.jwtService.sign(payload, {
            expiresIn: '15m',
        });

        const refreshToken = this.jwtService.sign(payload, {
            expiresIn: '7d',
        });

        // DB에 refreshToken 저장
        await this.prisma.authSession.create({
            data: {
                userId,
                refreshToken,
                expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 7)
            },
        });

        return { accessToken, refreshToken };
    }

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


    // 로그인
    async login(provider: 'google' | 'kakao' | 'naver', accessToken: string) {
        const profile = await this.fetchProfile(provider, accessToken);
        const user = await this.prisma.user.findUnique({
            where: { provider_providerId: { provider, providerId: String(profile.id) } },
        });

        if (!user) {
            throw new NotFoundException({ signupRequired: true, provider, profile });
        }

        return this.createTokens(user.id);
    }

    // 회원가입
    async signup(provider: 'google' | 'kakao' | 'naver', accessToken: string, nickname: string, character: string) {
        const profile = await this.fetchProfile(provider, accessToken);

        let user = await this.prisma.user.findUnique({
            where: { provider_providerId: { provider, providerId: String(profile.id) } },
        });

        if (!user) {
            user = await this.prisma.user.create({
                data: {
                    provider,
                    providerId: String(profile.id),
                    email: profile.email,
                    nickname,
                    character,
                },
            });
        }

        return this.createTokens(user.id);
    }

    // refresh token으로 access 재발급
    async refresh(refreshToken: string) {
        try {
            const payload = this.jwtService.verify(refreshToken);
            const session = await this.prisma.authSession.findUnique({ where: { refreshToken } });

            if (!session) throw new UnauthorizedException('Invalid refresh token');

            return this.createTokens(payload.sub);
        } catch {
            throw new UnauthorizedException('Invalid refresh token');
        }
    }

    async logout(refreshToken: string) {
        await this.prisma.authSession.delete({ where: { refreshToken } });
        return { message: 'Logged out' };
    }



}
