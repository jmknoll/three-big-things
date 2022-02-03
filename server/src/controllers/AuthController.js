"use strict";
var __awaiter =
  (this && this.__awaiter) ||
  function (thisArg, _arguments, P, generator) {
    function adopt(value) {
      return value instanceof P
        ? value
        : new P(function (resolve) {
            resolve(value);
          });
    }
    return new (P || (P = Promise))(function (resolve, reject) {
      function fulfilled(value) {
        try {
          step(generator.next(value));
        } catch (e) {
          reject(e);
        }
      }
      function rejected(value) {
        try {
          step(generator["throw"](value));
        } catch (e) {
          reject(e);
        }
      }
      function step(result) {
        result.done
          ? resolve(result.value)
          : adopt(result.value).then(fulfilled, rejected);
      }
      step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
  };
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod };
  };
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const bcrypt_1 = __importDefault(require("bcrypt"));
const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");
const prisma = new client_1.PrismaClient();
function oauth(req, res, next) {
  return __awaiter(this, void 0, void 0, function* () {
    try {
      const client = new OAuth2Client(process.env.GAPI_CLIENT_ID);
      const { token, tzOffset } = req.body;
      const ticket = yield client.verifyIdToken({
        idToken: token,
        audience: process.env.GAPI_CLIENT_ID,
      });
      const { _name, email } = ticket.getPayload();
      const user = yield prisma.user.upsert({
        where: { email: email },
        update: {},
        create: {
          email: email,
          timezone_offset: tzOffset,
        },
      });
      req.body.dbUser = user;
      next();
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
}
function comparePassword(user, password) {
  if (!user.password) {
    return false;
  }
  return bcrypt_1.default.compareSync(user.password, password);
}
function authenticate(req, res, next) {
  return __awaiter(this, void 0, void 0, function* () {
    try {
      const user = yield prisma.user.findUnique({
        where: { email: req.body.id },
      });
      if (!user) {
        res.status(401).json({ error: "Incorrect username or password" });
        return;
      }
      if (comparePassword(user, req.body.password)) {
        req.body.dbUser = user;
        next();
      } else {
        res.status(401).json({ error: "Incorrect username or password" });
      }
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
}
function generateJWT(req, res, next) {
  return __awaiter(this, void 0, void 0, function* () {
    if (req.body.dbUser) {
      const jwtPayload = { id: req.body.dbUser.id };
      const jwtSecret = process.env.JWT_SECRET_KEY;
      req.body.token = jwt.sign(jwtPayload, jwtSecret, {
        // If JWT_EXP_TIME is null, you have bigger problems
        expiresIn: parseInt(process.env.JWT_EXP_TIME),
      });
    }
    next();
  });
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
function returnJWT(req, res) {
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
