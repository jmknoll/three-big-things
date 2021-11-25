module.exports = (sequelize, Sequelize) => {
  const Goal = sequelize.define(
    "Goal",
    {
      id: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
      },
      name: {
        type: Sequelize.TEXT,
        required: true,
      },
      content: {
        type: Sequelize.TEXT,
        required: true,
      },
      period: {
        type: Sequelize.TEXT,
        required: true,
      },
      status: {
        type: Sequelize.TEXT,
        required: true,
      },
      archived: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
      },
    },
    {
      underscored: true,
    }
  );
  return Goal;
};
