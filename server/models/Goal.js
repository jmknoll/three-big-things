const uuidv1 = require("uuid/v1");
const { sequelize, Sequelize } = require("../db");

const Goal = sequelize.define("goals", {
  id: {
    type: Sequelize.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  content: {
    type: DataTypes.TEXT,
    required: true
  },
  period: {
    type: DataTypes.TEXT,
    required: true
  }
});

module.exports = Goal;
