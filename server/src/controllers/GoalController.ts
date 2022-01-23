import { Request, Response, NextFunction } from "express";
import { PrismaClient } from "@prisma/client";
import moment from "moment";
// const db = require("../models");
// const Goal = db.Goal;
// const User = db.User;

const prisma = new PrismaClient();

async function create(req: Request, res: Response) {
  if (!req.body.content) {
    res.status(400).send({
      message: "Content can not be empty!",
    });
    return;
  }

  try {
    const updateFields = {
      name: req.body.name,
      content: req.body.content,
      period: req.body.period,
      status: req.body.status,
    };

    const goal = await prisma.goal.upsert({
      where: {
        id: req.body.id,
      },
      update: {
        ...updateFields,
      },
      create: {
        id: req.body.id,
        user_id: req.body.user_id,
        ...updateFields,
      },
    });

    res.status(200).send(goal);
  } catch (e: any) {
    res.status(500).send({ error: e.message || "Error creating goal." });
  }
}

async function update(req: Request, res: Response) {
  const { id } = req.params;
  if (!req.body.content) {
    res.status(400).send({
      message: "Content can not be empty!",
    });
    return;
  }

  try {
    const [status, created] = await Goal.update(
      {
        archived: req.body.archived,
        name: req.body.name,
        content: req.body.content,
        period: req.body.period,
        status: req.body.status,
      },
      {
        where: {
          id: id,
        },
        returning: true,
        raw: true,
      }
    );
    res.status(200).send(created);
  } catch (e) {
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

async function updateGoalStatus(
  req: Request,
  res: Response,
  next: NextFunction
) {
  next();
  // this is for automatic archiving - might come back later
  // const archived = JSON.parse(req.query.archived);
  // if (!archived) {
  //   const user = await User.findByPk(req.user_id, { raw: true });
  //   const goals = await Goal.findAll({
  //     where: {
  //       user_id: req.user_id,
  //       archived,
  //     },
  //     raw: true,
  //   });
  //   ids = goals.map((goal) => shouldArchive(goal, user.timezone_offset));
  //   await Goal.update(
  //     {
  //       archived: true,
  //     },
  //     {
  //       where: {
  //         id: ids,
  //       },
  //     }
  //   );
  // }
  // next();
}

function findAll(req: Request, res: Response) {
  const archived = JSON.parse(req.query.archived);
  Goal.findAll({
    where: {
      user_id: req.user_id,
      archived,
    },
    order: [["updatedAt", "DESC"]],
  })
    .then((data) => res.status(201).send(data))
    .catch((e: any) => {
      res.status(500).send({ error: e.message });
    });
}

function destroy(req: Request, res: Response) {
  Goal.destroy({
    where: {
      id: req.params.id,
    },
  })
    .then((data) => {
      res.status(200).send({ id: req.params.id });
    })
    .catch((e: any) => {
      res.status(500).send({ error: e.message });
    });
}

module.exports = {
  create,
  update,
  findAll,
  updateGoalStatus,
  destroy,
};
