module.exports = (sequelize, Sequelize) => {
  const Goal = sequelize.define(
    "goals",
    {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true
      },
      user_id: {
        type: Sequelize.INTEGER,
        allowNull: false
      },
      content: {
        type: Sequelize.TEXT,
        required: true
      },
      period: {
        type: Sequelize.TEXT,
        required: true
      }
    },
    {
      underscored: true
    }
  );
  return Goal;
};
