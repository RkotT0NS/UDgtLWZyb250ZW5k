FROM node:24.16.0-alpine AS base
WORKDIR /app
# Install dependencies
COPY package*.json ./
RUN npm ci
COPY . .

# Application building container
FROM base AS build
RUN npm run build

# Development container
FROM base AS dev
EXPOSE 4200
CMD ["npm", "start"]


FROM nginx:1.31.1-alpine AS prod
WORKDIR /app
COPY --from=build /app/dist/olympic-games-starter/browser/ .
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
