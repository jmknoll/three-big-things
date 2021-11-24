const db = require("../models");
const Goal = db.Goal;

async function create(req, res) {
  if (!req.body.content) {
    res.status(400).send({
      message: "Content can not be empty!",
    });
    return;
  }

  try {
    const [record, created] = await Goal.upsert(
      {
        id: req.body.id,
        user_id: req.user_id,
        name: req.body.name,
        content: req.body.content,
        period: req.body.period,
        status: req.body.status,
      },
      { returning: true }
    );
    res.status(200).send(record);
  } catch (err) {
    res.status(500).send({ error: e.message || "Error creating goal." });
  }
}

function findAll(req, res) {
  Goal.findAll({
    where: {
      user_id: req.user_id,
    },
    order: [["updatedAt", "DESC"]],
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
