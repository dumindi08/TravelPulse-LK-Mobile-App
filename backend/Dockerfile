# TravelPulse LK — Backend Service Dockerfile
# Group 10 (SE5104 Mini Project)
FROM node:20-alpine

WORKDIR /app

# Copy package manifests and install dependencies
COPY package*.json ./
RUN npm install --omit=dev

# Copy application source code
COPY src/ ./src/

# Expose backend REST port
EXPOSE 5000

ENV PORT=5000
ENV NODE_ENV=production

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/health || exit 1

# Start Express server
CMD ["node", "src/server.js"]

