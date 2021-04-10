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

const sslOptions = {
  dialectOptions: {
    ssl: true,
  },
};

module.exports = {
  dbConfig,
  // Keys map to process.env.NODE_ENV
  development: {
    ...dbConfig,
  },
  staging: {
    ...dbConfig,
    ...sslOptions,
  },
  production: {
    use_env_variable: "DATABASE_URL",
    ...dbConfig,
    ...sslOptions,
  },
};
