# Dockerfile
FROM node:22-slim

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 설치
COPY package.json yarn.lock ./
RUN yarn install

# Prisma client 생성
COPY prisma ./prisma
RUN yarn prisma generate

# 소스 복사
COPY . .

# 포트 열기
EXPOSE 3000

