# Create an image for the weather-app
FROM node
LABEL version="1.0"
RUN mkdir -p /var/node
ADD src/ /var/node/
WORKDIR /var/node
RUN npm install
EXPOSE 3000
CMD ./bin/www
