FROM node:22-alpine AS base

#ARG GITLAB_API_TOKEN

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS install-dependencies

RUN corepack enable pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store pnpm fetch --frozen-lockfile
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store pnpm install --frozen-lockfile

FROM base AS build-next-app

RUN corepack enable pnpm
WORKDIR /app

COPY --from=install-dependencies /app/node_modules ./node_modules
COPY . .

RUN --mount=type=cache,id=next,target=/root/.local/share/next pnpm run build


# Step 3: Create the final runnable image
FROM base AS prepare-node-server

WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nextjs

COPY --from=build-next-app --chown=nextjs:nodejs app/.next/standalone/ ./
COPY --from=build-next-app --chown=nextjs:nodejs app/.next/static .next/static

# Ensure nextjs user has read/write access to /app
RUN chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000
ENV PORT 3000

# Set the entrypoint to the script
CMD ["node", "server.js"]