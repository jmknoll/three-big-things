require("dotenv").config();
var parse = require("pg-connection-string").parse;

const { host, port, user, password, database } = parse(
  process.env.DATABASE_URL
);

const dbConfig = {
  username: user,
  password,
  database,
  host,
  port,
  dialect: "postgres",
};

module.exports = {
  development: {
    ...dbConfig,
    dialect: "postgresql",
    keepDefaultTimezone: false,
    timezone: "+00:00",
  },
  staging: {
    ...dbConfig,
    dialect: "postgresql",
    keepDefaultTimezone: false,
    timezone: "+00:00",
    dialectOptions: {
      ssl: {
        rejectUnauthorized: false,
      },
    },
  },
  production: {
    use_env_variable: "DATABASE_URL",
    ...dbConfig,
    dialect: "postgresql",
    keepDefaultTimezone: false,
    timezone: "+00:00",
    dialectOptions: {
      ssl: {
        rejectUnauthorized: false,
      },
    },
  },
};
