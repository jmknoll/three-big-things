const db = require("../models");
const User = db.User;

function create(req, res) {
  if (!req.body) {
    res.status(400).send({
      message: "Content can not be empty!",
    });
    return;
  }

  User.create({
    email: req.body.email,
    password: req.body.password,
  })
    .then((user) => {
      res.status(201).send(user);
    })
    .catch((e) => {
      res.status(500).send({ error: e.message || "Error creating user" });
    });
}

module.exports = {
  create,
};
