FROM node:16-alpine

WORKDIR /app

COPY ["package.json", "yarn.lock", "./"]

RUN npm install
COPY . .
EXPOSE 8080

RUN npx prisma generate
CMD ["npm", "run", "start:dev"]