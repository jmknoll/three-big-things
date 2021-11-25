const db = require("../models");
const Goal = db.Goal;
const User = db.User;
const moment = require("moment");

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

function shouldArchive(record, timezone_offset) {
  let created = moment.utc(record.createdAt);
  let created_local = created.subtract(timezone_offset, "minutes");
  let now_local = moment.utc().subtract(timezone_offset, "minutes");
  if (record.period === "DAILY" && !created_local.isSame(now_local, "day")) {
    return record.id;
  }
  if (record.period === "WEEKLY" && !created_local.isSame(now_local, "week")) {
    return record.id;
  }

  return -1;
}

async function updateGoalStatus(req, res, next) {
  const archived = JSON.parse(req.query.archived);
  if (!archived) {
    const user = await User.findByPk(req.user_id, { raw: true });
    const goals = await Goal.findAll({
      where: {
        user_id: req.user_id,
        archived,
      },
      raw: true,
    });
    ids = goals.map((goal) => shouldArchive(goal, user.timezone_offset));
    console.log(ids);
    await Goal.update(
      {
        archived: true,
      },
      {
        where: {
          id: ids,
        },
      }
    );
  }
  next();
}

function findAll(req, res) {
  const archived = JSON.parse(req.query.archived);
  Goal.findAll({
    where: {
      user_id: req.user_id,
      archived,
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
  updateGoalStatus,
  destroy,
};
