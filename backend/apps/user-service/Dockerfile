FROM node:20.19-alpine

WORKDIR /app

COPY package.json package-lock.json ./
COPY packages ./packages
COPY apps ./apps

RUN npm install

EXPOSE 3002

CMD ["npm", "-w", "@auratalk/user-service", "run", "dev"]

