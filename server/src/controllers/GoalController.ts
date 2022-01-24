import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function create(req: Request, res: Response) {
  if (!req.body.name) {
    res.status(400).send({
      message: "Goal cannot be empty!",
    });
    return;
  }

  try {
    const goal = await prisma.goal.create({
      data: {
        name: req.body.name,
        content: req.body.content,
        period: req.body.period,
        status: req.body.status,
        user_id: req.body.user_id,
      },
    });

    res.status(200).send(goal);
  } catch (e: any) {
    res.status(500).send({ error: e.message || "Error creating goal." });
  }
}

async function update(req: Request, res: Response) {
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
    const archivedStr: string = req.query.archived as string;
    const archived: boolean = archivedStr === "true" ? true : false;

    const goals = await prisma.goal.findMany({
      where: {
        user_id: req.body.user_id,
        archived: archived,
      },
      orderBy: {
        created_at: "asc",
      },
    });

    res.status(200).send(goals);
  } catch (e: any) {
    console.log(e);
    res
      .status(500)
      .send({ error: e.message || "Error fetching goals for user." });
  }
}

async function destroy(req: Request, res: Response) {
  try {
    const _id = req.params.id as string;
    const id = parseInt(_id);
    const goal = await prisma.goal.delete({
      where: {
        id,
      },
    });
    res.status(200).send({ id: goal.id });
  } catch (e: any) {
    res.status(500).send({ error: e.message || "Error destroying goal." });
  }
}

module.exports = {
  findAll,
  create,
  update,
  destroy,
};
