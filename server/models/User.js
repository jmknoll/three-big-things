const bcrypt = require("bcrypt");
const uuidv1 = require("uuid/v1");

module.exports = (sequelize, Sequelize) => {
  const User = sequelize.define(
    "User",
    {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      name: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      email: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: {
          args: true,
          msg: "Username already exists",
        },
      },
      password: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      refresh_token: {
        type: Sequelize.UUID,
        allowNull: true,
        unique: {
          args: true,
          msg: "Bad luck. Refresh token already exists",
        },
        defaultValue: uuidv1(),
      },
    },
    {
      underscored: true,
    }
  );

  User.associate = (models) => {
    User.hasMany(models.Goal, { as: "goals", foreignKey: "UserId" });
  };

  User.beforeCreate((user) => {
    const hash = bcrypt.hashSync(user.password, 10);
    user.password = hash;
    user.refresh_token = uuidv1();
  });

  User.prototype.comparePassword = function (somePassword) {
    return bcrypt.compareSync(somePassword, this.password);
  };

  return User;
};
