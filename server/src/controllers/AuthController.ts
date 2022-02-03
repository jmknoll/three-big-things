import { Request, Response, NextFunction } from "express";
import { PrismaClient, User } from "@prisma/client";
// import bcrypt from "bcrypt";

const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");

const prisma = new PrismaClient();

async function oauth(req: Request, res: Response, next: NextFunction) {
  try {
    const client = new OAuth2Client(process.env.GAPI_CLIENT_ID);
    const { token, tzOffset } = req.body;
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: process.env.GAPI_CLIENT_ID,
    });

    const { _name, email } = ticket.getPayload();

    const user = await prisma.user.upsert({
      where: { email: email },
      update: {},
      create: {
        email: email,
        timezone_offset: tzOffset,
      },
    });

    req.body.dbUser = user;

    next();
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
}

// function comparePassword(user: User, password: string): boolean {
//   if (!user.password) {
//     return false;
//   }
//   return bcrypt.compareSync(user.password, password);
// }

// async function authenticate(req: Request, res: Response, next: NextFunction) {
//   try {
//     const user = await prisma.user.findUnique({
//       where: { email: req.body.id },
//     });

//     if (!user) {
//       res.status(401).json({ error: "Incorrect username or password" });
//       return;
//     }

//     if (comparePassword(user, req.body.password)) {
//       req.body.dbUser = user;
//       next();
//     } else {
//       res.status(401).json({ error: "Incorrect username or password" });
//     }
//   } catch (e: any) {
//     res.status(500).json({ error: e.message });
//   }
// }

async function generateJWT(req: Request, res: Response, next: NextFunction) {
  if (req.body.dbUser) {
    const jwtPayload = { id: req.body.dbUser.id };
    const jwtSecret = process.env.JWT_SECRET_KEY;
    req.body.token = jwt.sign(jwtPayload, jwtSecret, {
      // If JWT_EXP_TIME is null, you have bigger problems
      expiresIn: parseInt(process.env.JWT_EXP_TIME!),
    });
  }
  next();
}

// function refreshJWT(req: Request, res: Response, next: NextFunction) {

//   User.findOne({
//     where: {
//       username: req.body.username,
//       refresh_token: req.body.refresh_token,
//     },
//   })
//     .then((user) => {
//       req.dbUser = user;
//       next();
//     })
//     .catch(() => {
//       res.status(401).json({ error: "Invalid username or token" });
//     });
// }

function returnJWT(req: Request, res: Response) {
  if (req.body.dbUser && req.body.token) {
    res.status(201).json({ token: req.body.token, user: req.body.dbUser });
  } else {
    res.status(401).json({ error: "Unauthorized" });
  }
}

module.exports = {
  oauth,
  // authenticate,
  generateJWT,
  // refreshJWT,
  returnJWT,
};
