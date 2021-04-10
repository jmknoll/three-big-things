if (process.env.NODE_ENV !== "production") {
  require("dotenv").config();
}

const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const port = process.env.PORT || 8000;
const passport = require("passport");
const db = require("./db");

const userCtrl = require("./controllers/UserController");
const authCtrl = require("./controllers/AuthController");
const router = express.Router();

const app = express();
app.use(cors());
app.use(passport.initialize());
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: false,
  })
);

app.get("/", (req, res) => {
  res.json({ message: "Welcome to three big things." });
});

require("./routes")(app);

db.sequelize.sync();

app.listen(port, () => {
  console.log("Express listening on port:", port);
});
