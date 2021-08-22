if (process.env.NODE_ENV !== "production") {
  require("dotenv").config();
}

const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const port = process.env.PORT || 8080;
const passport = require("passport");

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

app.listen(port, () => {
  console.log("Express listening on port:", port);
});
