const User = require("../models/User");

function create(req, res) {
  User.create({
    email: req.body.email,
    password: req.body.password
  })
    .then(user => {
      res.status(201).json(user);
    })
    .catch(e => {
      res.status(500).json({ error: e.message });
    });
}

module.exports = {
  create
};
