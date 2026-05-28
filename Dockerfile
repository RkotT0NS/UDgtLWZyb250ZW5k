FROM node:24.16.0-alpine AS base
WORKDIR /app
# Install dependencies
COPY package*.json ./
RUN npm ci
COPY . .

# Application building container
FROM base AS build
WORKDIR /app

RUN npm run build

# Development container
FROM base AS dev
WORKDIR /app
EXPOSE 4200

CMD ["npm", "start", "--", "--host", "0.0.0.0"]

# === Test Stage ===
# For headless testing
# Runs 'mvn test' against the compiled code
FROM base AS test
WORKDIR /app

RUN apk add --no-cache chromium
ENV CHROME_BIN=/usr/bin/chromium-browser

CMD ["npm", "test"]

FROM nginx:1.31.1-alpine AS prod
WORKDIR /app
COPY --from=build /app/dist/olympic-games-starter/browser/ .
COPY nginx/nginx.conf /etc/nginx/nginx.conf
