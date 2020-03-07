const db = require("../db");
const Goal = db.Goal;

function create(req, res) {
  if (!req.body.content) {
    res.status(400).send({
      message: "Content can not be empty!"
    });
    return;
  }

  Goal.create({
    user_id: req.body.user_id,
    content: req.body.content,
    period: req.body.period
  })
    .then(goal => {
      res.status(201).send(goal);
    })
    .catch(e => {
      res.status(500).send({ error: e.message || "Error creating goal." });
    });
}

function findAll(req, res) {
  Goal.findAll()
    .then(data => res.status(201).send(data))
    .catch(e => {
      res.status(500).send({ error: e.message });
    });
}

module.exports = {
  create,
  findAll
};
