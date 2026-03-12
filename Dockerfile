# ============================================
# Stage 1: 의존성 설치
# ============================================
FROM node:22-alpine AS deps
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# lockfile과 package.json만 먼저 복사해 레이어 캐시 활용
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

# ============================================
# Stage 2: 빌드
# ============================================
FROM node:22-alpine AS builder
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# deps 스테이지에서 node_modules 가져오기
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js 빌드 (standalone 출력 사용)
ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm build

# ============================================
# Stage 3: 프로덕션 실행
# ============================================
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# standalone 출력에는 node_modules가 포함되어 있어 추가 설치 불필요
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# standalone 빌드 결과물 복사
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
