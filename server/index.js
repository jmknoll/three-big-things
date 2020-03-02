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
const UserCtrl = require("./controllers/UserController");
const authCtrl = require("./controllers/AuthController");
const router = express.Router();

const app = express();
app.use(cors());
app.use(passport.initialize());
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: false
  })
);

User.sync();
app.listen(port, () => console.log(`Example app listening on port ${port}!`));

// Routing

//app.get("/", (req, res) => res.send("Hello World!"));

// app.post("/users", function(req, res, next) {
//   UserCtrl.create(req, res);
// });

router.route("/users").post(UserCtrl.create);

router
  .route("/auth")
  .post(authCtrl.authenticate, authCtrl.generateJWT, authCtrl.returnJWT);

app.use("/", router);
