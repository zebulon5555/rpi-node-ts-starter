FROM node:20-alpine AS build

WORKDIR /app
COPY package.json package-lock.json ./
# --include=dev avoids a host/build environment that globally omits TypeScript.
RUN npm ci --include=dev && test -x node_modules/.bin/tsc
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

FROM node:20-alpine AS production

WORKDIR /app
ENV NODE_ENV=production
# Reuse the build-stage dependency tree, then remove dev-only packages. This keeps
# the ARM BuildKit build from running two npm network installs concurrently.
COPY --from=build /app/package.json /app/package-lock.json ./
COPY --from=build /app/node_modules ./node_modules
# npm is build-only; remove it from the runtime image after pruning dependencies.
RUN npm install --global npm@10 && npm prune --omit=dev && npm cache clean --force \
    && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx \
    && rm -f package.json package-lock.json
COPY --from=build /app/dist ./dist

USER node
EXPOSE 3000
CMD ["node", "dist/index.js"]
