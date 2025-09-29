import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {

    constructor(private readonly authService: AuthService) { }


    @Post('login/google')
    async googleLogin(@Body() body: { accessToken: string }) {
        return this.authService.login('google', body.accessToken);
    }

    @Post('login/kakao')
    async kakaoLogin(@Body() body: { accessToken: string }) {
        return this.authService.login('kakao', body.accessToken);
    }

    @Post('login/naver')
    async naverLogin(@Body() body: { accessToken: string }) {
        return this.authService.login('naver', body.accessToken);
    }

    @Post('signup/google')
    async googleSignup(@Body() body: { accessToken: string }) {
        return this.authService.signup('google', body.accessToken);
    }

    @Post('signup/kakao')
    async kakaoSignup(@Body() body: { accessToken: string }) {
        return this.authService.signup('kakao', body.accessToken);
    }

    @Post('signup/naver')
    async naverSignup(@Body() body: { accessToken: string }) {
        return this.authService.signup('naver', body.accessToken);
    }

    @Post('logout')
    async logout(@Body() body: { accessToken: string }) {
        return this.authService.logout(body.accessToken);
    }

}
