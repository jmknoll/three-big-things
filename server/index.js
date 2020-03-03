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

const userCtrl = require("./controllers/UserController");
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

app.listen(port, () => console.log(`Example app listening on port ${port}!`));

router.route("/users").post(userCtrl.create);

router
  .route("/auth")
  .post(authCtrl.authenticate, authCtrl.generateJWT, authCtrl.returnJWT);

app.use("/", router);
