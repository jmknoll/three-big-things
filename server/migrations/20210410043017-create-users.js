"use strict";
const uuidv1 = require("uuid/v1");

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable(
      "users",
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
        created_at: {
          // allowNull: false,
          type: Sequelize.DATE,
        },
        updated_at: {
          // allowNull: false,
          type: Sequelize.DATE,
        },
      },
      {
        underscored: true,
      }
    );
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("users");
  },
};
