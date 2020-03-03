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
db.users = require("./models/User.js")(sequelize, Sequelize);
db.goals = require("./models/Goal.js")(sequelize, Sequelize);

db.users.hasMany(db.goals);
db.goals.belongsTo(db.users);

module.exports = db;
