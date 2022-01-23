"use strict";

const sequelize = require("sequelize");

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.changeColumn("goals", "content", {
      type: Sequelize.TEXT,
      allowNull: true,
    });
  },

  down: (queryInterface, Sequelize) => {
    return queryInterface.changeColumn("goals", "content", {
      type: Sequelize.TEXT,
      allowNull: false,
    });
  },
};
