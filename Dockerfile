FROM node:12.16.1-alpine AS build

RUN apk add --update --no-cache \
  python \
  make \
  g++ \
  git

WORKDIR /src
COPY ./package* ./

RUN npm ci

COPY . .

RUN npm run lint
RUN npm run test
RUN npm run build

RUN npm prune --production

FROM node:12.16.1-alpine

RUN apk add --update --no-cache curl

EXPOSE 5000

WORKDIR /usr/src/service

COPY --from=build /src/node_modules node_modules
COPY --from=build /src/dist dist

HEALTHCHECK --interval=5s \
  --timeout=5s \
  --retries=6 \
  CMD curl -fs http://localhost:5000/ || exit 1

USER node

CMD ["npm", "run start:prod"]