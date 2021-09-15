FROM node:14-alpine AS base

WORKDIR /usr/app

# Build front app
FROM base AS front-build
COPY ./front ./
RUN npm install
RUN npm run build 

# Build back app
FROM base AS back-build
COPY ./back .
RUN npm install
RUN npm run build

# Release
FROM base AS release 
COPY --from=front-build /usr/app/dist ./public
COPY --from=back-build /usr/app/dist ./
COPY ./back/package*.json ./
RUN npm ci --only=production


EXPOSE 3001
ENV PORT=3001
ENV STATIC_FILES_PATH=./public
ENV API_MOCK=true

ENTRYPOINT [ "node", "index" ]