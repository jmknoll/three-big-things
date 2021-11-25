"use strict";

module.exports = {
  up: (queryInterface, Sequelize) => {
    return Promise.all([
      queryInterface.addColumn("users", "last_login", {
        type: Sequelize.DATE,
      }),
      queryInterface.addColumn("users", "streak", {
        type: Sequelize.INTEGER,
      }),
    ]);
  },

  down: (queryInterface, Sequelize) => {
    return Promise.all([
      queryInterface.removeColumn("users", "last_login"),
      queryInterface.removecolumn("users", "streak"),
    ]);
  },
};
