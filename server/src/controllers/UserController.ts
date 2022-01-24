import { Request, Response, NextFunction } from "express";
import moment from "moment";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function me(req: Request, res: Response, next: NextFunction) {
  try {
    const user = await prisma.user.findUnique({
      where: {
        id: req.body.user_id,
      },
    });
    req.body.dbUser = user;
    next();
  } catch (e: any) {
    res.status(500).send({ error: e.message || "Error fetching user" });
  }
}

async function updateAccountDetails(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    // update timezone if it has changed
    let tzOffset: any = req.query.tzOffset;
    tzOffset = parseInt(tzOffset);
    if (tzOffset !== req.body.dbUser.timezone_offset) {
      let user = await prisma.user.update({
        where: { id: req.body.dbUser.id },
        data: {
          timezone_offset: tzOffset,
        },
      });

      req.body.dbUser = user;
    }

    // update user streak if neccesary
    let last_login = moment.utc(req.body.dbUser.last_login);
    let timezone_offset = req.body.dbUser.timezone_offset;
    let local_last_login = last_login.subtract(timezone_offset, "minutes");
    let local_now = moment().subtract(timezone_offset, "minutes");

    const last_day = local_last_login.dayOfYear();
    const now_day = local_now.dayOfYear();
    const diff = now_day - last_day;

    if (diff !== 0) {
      let newStreak = 0;
      if (diff === 1 || (now_day === 1 && diff === -364)) {
        newStreak = req.body.dbUser.streak + 1;
      } else {
        newStreak = 1;
      }
    }

    next();
  } catch (err: any) {
    console.log(err.message);
    res.status(500).send({ error: err.message || "Error fetching user" });
  }
}

async function create(req: Request, res: Response) {
  if (!req.body) {
    res.status(400).send({
      message: "Content can not be empty!",
    });
    return;
  }

  try {
    const user = await prisma.user.create({
      data: {
        email: req.body.email,
        password: req.body.password,
      },
    });

    res.status(200).send(user);
  } catch (e: any) {
    res.status(500).send({ error: e.message || "Error creating user" });
  }
}

module.exports = {
  me,
  updateAccountDetails,
  create,
};
