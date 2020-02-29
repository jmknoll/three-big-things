if (process.env.NODE_ENV !== "production") {
  require("dotenv").config();
}

const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const port = process.env.PORT || 8000;
const { sequelize } = require("./db");
const passport = require("passport");
const passportJWT = require("passport-jwt");
const User = require("./models/User");

const app = express();
app.use(cors());
app.use(passport.initialize());
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: false
  })
);

app.get("/", (req, res) => res.send("Hello World!"));

app.listen(port, () => console.log(`Example app listening on port ${port}!`));

const createUser = async ({ email, password }) => {
  return await User.create({ email, password });
};

const getAllUsers = async () => {
  return await User.findAll();
};

const getUser = async obj => {
  return await User.findOne({
    where: obj
  });
};

let ExtractJwt = passportJWT.ExtractJwt;

let JwtStrategy = passportJWT.Strategy;

let jwtOptions = {};
jwtOptions.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();
jwtOptions.secretOrKey = process.env.JWT_SECRET_KEY;

app.get("/users", function(req, res) {
  getAllUsers().then(user => res.json(user));
});

app.post("/register", function(req, res, next) {
  const { email, password } = req.body;
  createUser({ email, password }).then(user =>
    res.json({ user, msg: "account created succesfully" })
  );
});

app.post("login", async function(req, res, next) {
  const { email, passsword } = req.body;
});
