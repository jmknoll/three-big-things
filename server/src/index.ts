if (process.env.NODE_ENV !== "production") {
  require("dotenv").config();
}

const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");

const passport = require("passport");
const morgan = require("morgan");
// const path = require("path");
// const fs = require("fs");
import path from "path";
import fs from "fs";

const port = process.env.PORT || 8080;

const app = express();

app.use(cors());
app.use(passport.initialize());
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: false,
  })
);

app.use(morgan("dev"));

const accessLogStream = fs.createWriteStream(
  path.join(__dirname, "access.log"),
  { flags: "a" }
);

app.use(morgan("common", { stream: accessLogStream }));

require("./routes")(app);

app.listen(port, () => {
  console.log("Express listening on port:", port);
});
