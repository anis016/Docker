FROM node as build
RUN mkdir -p /var/node
ADD src/ /var/node/
WORKDIR /var/node
RUN npm install

FROM node:alpine
ARG VERSION=v1.1
ARG ENV="production"
LABEL version=${VERSION}
ENV NODE_ENV=${ENV}
COPY --from=build /var/node /var/node
WORKDIR /var/node
EXPOSE 3000
ENTRYPOINT ["./bin/www"]