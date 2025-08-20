FROM node:18-alpine

RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    curl \
    bash \
    iptables \
    iproute2 \
    net-tools

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY . .

RUN mkdir -p /app/uploads /app/configs /app/logs

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
RUN chown -R nextjs:nodejs /app
USER nextjs

EXPOSE 80 3001 3128 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

CMD ["node", "server.js"]
