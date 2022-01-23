"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    return Promise.all([
      queryInterface.addColumn("goals", "name", {
        type: Sequelize.STRING,
      }),
      queryInterface.addColumn("goals", "status", {
        type: Sequelize.STRING,
      }),
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    return Promise.all([
      queryInterface.removeColumn("goals", "name"),
      queryInterface.removeColumn("goals", "status"),
    ]);
  },
};
