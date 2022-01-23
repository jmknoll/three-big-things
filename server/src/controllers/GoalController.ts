import { Request, Response, NextFunction } from "express";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

interface Query {
  archived: string | undefined;
}

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
    const goal = await prisma.goal.update({
      where: {
        id: req.body.id,
      },
      data: {
        name: req.body.name,
        content: req.body.content,
        period: req.body.period,
        status: req.body.status,
      },
    });

    res.status(200).send(goal);
  } catch (e: any) {
    res.status(500).send({ error: e.message || "Error creating goal." });
  }
}

async function findAll(req: Request, res: Response) {
  try {
    const archived: string = JSON.parse(req.query.archived as string);

    const goals = await prisma.goal.findMany({
      where: {
        user_id: req.body.user_id,
      },
      orderBy: {
        created_at: "desc",
      },
    });
    res.status(200).send(goals);
  } catch (e: any) {
    res
      .status(500)
      .send({ error: e.message || "Error fetching goals for user." });
  }
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
  findAll,
  create,
  update,
  destroy,
};
