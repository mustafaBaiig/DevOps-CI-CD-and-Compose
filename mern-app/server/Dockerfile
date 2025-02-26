
FROM node:18-alpine AS builder


WORKDIR /app


COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy the rest of the app
COPY . .

# Expose the backend port
EXPOSE 3000


RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser


CMD ["node", "server.js"]
