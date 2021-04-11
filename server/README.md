## Three Big Things [Backend]

Three big things is a straightforward, opinionated system for getting things done.
Parent repository: https://github.com/jmknoll/three-big-things

### Run

- Clone the parent repository with `git clone git@github.com:jmknoll/three-big-things.git`
- `cd server && npm install`
- `npx sequelize-cli db:create && npx sequelize-cli db:migrate`
- `npm run serve`

### Deploy

Backebd deploys automatically to Heroku on merge to `master`
