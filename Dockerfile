FROM node:20.19.0-alpine AS base

WORKDIR /usr/src/app

FROM base AS deps 
COPY package*.json ./
RUN npm ci

FROM base AS builder
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM base AS main 
USER node 

COPY --chown=node:node --from=deps /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=builder /usr/src/app/static ./static
COPY --chown=node:node src ./src

EXPOSE 3000

CMD ["node", "src/server/app.js"]
