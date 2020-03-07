const jwt = require("jsonwebtoken");
const uuidv1 = require("uuid/v1");

const db = require("../db");
const User = db.User;

function authenticate(req, res, next) {
  User.findOne({
    where: {
      email: req.body.email
    }
  })
    .then(user => {
      if (user && user.comparePassword(req.body.password)) {
        req.dbUser = user;
        next();
      } else {
        res.status(401).json({ error: "Incorrect username or password" });
      }
    })
    .catch(e => {
      res.status(500).json({ error: e.message });
    });
}

async function generateJWT(req, res, next) {
  console.log("gen");
  if (req.dbUser) {
    const jwtPayload = { id: req.dbUser.id };
    const jwtSecret = process.env.JWT_SECRET_KEY;
    req.token = jwt.sign(jwtPayload, jwtSecret, {
      expiresIn: parseInt(process.env.JWT_EXP_TIME)
    });

    await req.dbUser.update({ refresh_token: uuidv1() }).catch(e => {
      res.status(500).json({ error: e.message });
    });
  }
  next();
}

function refreshJWT(req, res, next) {
  User.findOne({
    where: {
      username: req.body.username,
      refresh_token: req.body.refresh_token
    }
  })
    .then(user => {
      req.dbUser = user;
      next();
    })
    .catch(() => {
      res.status(401).json({ error: "Invalid username or token" });
    });
}

function returnJWT(req, res) {
  console.log("return");
  if (req.dbUser && req.token) {
    res
      .status(201)
      .json({ token: req.token, refresh_token: req.dbUser.refresh_token });
  } else {
    res.status(401).json({ error: "Unauthorized" });
  }
}

module.exports = {
  authenticate,
  generateJWT,
  refreshJWT,
  returnJWT
};
