const Sequelize = require("sequelize");

const sequelize = new Sequelize(
  process.env.DB_DATABASE,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    dialect: "postgres",
    port: 5432
  }
);

const db = {};

db.Sequelize = Sequelize;
db.sequelize = sequelize;

db.User = require("./models/User.js")(sequelize, Sequelize);
db.Goal = require("./models/Goal.js")(sequelize, Sequelize);

db.User.hasMany(db.Goal);
db.Goal.belongsTo(db.User);

module.exports = db;
