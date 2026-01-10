import { Body, Controller, Post, Param } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {

    constructor(private readonly authService: AuthService) { }

    @Post('login/:provider')
    async login(@Body() body: { accessToken: string }, @Param('provider') provider: 'google' | 'kakao' | 'naver') {
        return this.authService.login(provider, body.accessToken);
    }

    @Post('signup/:provider')
    async signup(
        @Body() body: { accessToken: string; nickname: string; character: string },
        @Param('provider') provider: 'google' | 'kakao' | 'naver',
    ) {
        return this.authService.signup(provider, body.accessToken, body.nickname, body.character);
    }

    @Post('refresh')
    async refresh(@Body() body: { refreshToken: string }) {
        return this.authService.refresh(body.refreshToken);
    }

    @Post('logout')
    async logout(@Body() body: { accessToken: string }) {
        return this.authService.logout(body.accessToken);
    }

}
