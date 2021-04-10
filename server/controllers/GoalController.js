const db = require("../models");
const Goal = db.Goal;

function create(req, res) {
  if (!req.body.content) {
    res.status(400).send({
      message: "Content can not be empty!",
    });
    return;
  }

  Goal.create({
    user_id: req.user_id,
    content: req.body.content,
    period: req.body.period,
  })
    .then((goal) => {
      res.status(201).send(goal);
    })
    .catch((e) => {
      res.status(500).send({ error: e.message || "Error creating goal." });
    });
}

function findAll(req, res) {
  Goal.findAll({
    where: {
      user_id: req.user_id,
    },
  })
    .then((data) => res.status(201).send(data))
    .catch((e) => {
      res.status(500).send({ error: e.message });
    });
}

function destroy(req, res) {
  Goal.destroy({
    where: {
      id: req.params.id,
    },
  })
    .then((data) => {
      res.status(200).send({ id: req.params.id });
    })
    .catch((e) => {
      res.status(500).send({ error: e.message });
    });
}

module.exports = {
  create,
  findAll,
  destroy,
};
