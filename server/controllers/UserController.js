const db = require("../models");
const User = db.User;
const moment = require("moment");

async function me(req, res, next) {
  try {
    const user = await User.findOne({
      where: {
        id: req.user_id,
      },
      attributes: [
        "id",
        "name",
        "email",
        "refresh_token",
        "last_login",
        "timezone_offset",
        "streak",
      ],
    });
    req.dbUser = user;
    next();
  } catch (e) {
    res.status(500).send({ error: e.message || "Error fetching user" });
  }
}

async function updateAccountDetails(req, res, next) {
  try {
    // update timezone if it has changed
    let { tzOffset } = req.query;
    tzOffset = parseInt(tzOffset);
    if (tzOffset !== req.dbUser.timezone_offset) {
      let res = await User.update(
        { timezone_offset: tzOffset },
        {
          where: { id: req.dbUser.id },
          returning: true,
          limit: 1,
          plain: true,
        }
      );
      req.dbUser = res[1];
    }
    // update user streak if neccesary
    let last_login = moment.utc(req.dbUser.last_login);
    let timezone_offset = req.dbUser.timezone_offset;
    local_last_login = last_login.subtract(timezone_offset, "minutes");
    local_now = moment().subtract(timezone_offset, "minutes");

    const last_day = local_last_login.dayOfYear();
    const now_day = local_now.dayOfYear();
    const diff = now_day - last_day;

    if (diff !== 0) {
      let newStreak = 0;
      if (diff === 1 || (now_day === 1 && diff === -364)) {
        newStreak = req.dbUser.streak + 1;
      } else {
        newStreak = 1;
      }

      let res = await User.update(
        { streak: newStreak, last_login: Date.now() },
        {
          where: { id: req.dbUser.id },
          returning: true,
          limit: 1,
          plain: true,
        }
      );
      req.dbUser = res[1];
    }

    next();
  } catch (err) {
    console.log(err.message);
    res.status(500).send({ error: err.message || "Error fetching user" });
  }
}

function create(req, res) {
  if (!req.body) {
    res.status(400).send({
      message: "Content can not be empty!",
    });
    return;
  }

  User.create({
    email: req.body.email,
    password: req.body.password,
  })
    .then((user) => {
      res.status(201).send(user);
    })
    .catch((e) => {
      res.status(500).send({ error: e.message || "Error creating user" });
    });
}

module.exports = {
  me,
  updateAccountDetails,
  create,
};
