const jwt = require("jsonwebtoken");
const uuidv1 = require("uuid/v1");
const { OAuth2Client } = require("google-auth-library");

const db = require("../models");
const User = db.User;

async function oauth(req, res, next) {
  try {
    const client = new OAuth2Client(process.env.GAPI_CLIENT_ID);
    const { token } = req.body;
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: process.env.GAPI_CLIENT_ID,
    });
    const { name, email } = ticket.getPayload();

    const user = await User.findOrCreate({
      where: {
        email,
      },
      defaults: {
        email,
        name,
      },
      attributes: ["id", "name", "email", "refresh_token"],
    });

    req.dbUser = user[0];

    next();
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}

function authenticate(req, res, next) {
  User.findOne({
    where: {
      email: req.body.email,
    },
  })
    .then((user) => {
      if (user && user.comparePassword(req.body.password)) {
        req.dbUser = user;
        next();
      } else {
        res.status(401).json({ error: "Incorrect username or password" });
      }
    })
    .catch((e) => {
      res.status(500).json({ error: e.message });
    });
}

async function generateJWT(req, res, next) {
  if (req.dbUser) {
    const jwtPayload = { id: req.dbUser.id };
    const jwtSecret = process.env.JWT_SECRET_KEY;
    req.token = jwt.sign(jwtPayload, jwtSecret, {
      expiresIn: parseInt(process.env.JWT_EXP_TIME),
    });
  }
  next();
}

function refreshJWT(req, res, next) {
  User.findOne({
    where: {
      username: req.body.username,
      refresh_token: req.body.refresh_token,
    },
  })
    .then((user) => {
      req.dbUser = user;
      next();
    })
    .catch(() => {
      res.status(401).json({ error: "Invalid username or token" });
    });
}

function returnJWT(req, res) {
  if (req.dbUser && req.token) {
    res.status(201).json({ token: req.token, user: req.dbUser });
  } else {
    res.status(401).json({ error: "Unauthorized" });
  }
}

module.exports = {
  oauth,
  authenticate,
  generateJWT,
  refreshJWT,
  returnJWT,
};
