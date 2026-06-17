FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json ./
COPY packages ./packages
COPY apps ./apps

RUN npm install

EXPOSE 8080

CMD ["npm", "-w", "@auratalk/gateway", "run", "dev"]

