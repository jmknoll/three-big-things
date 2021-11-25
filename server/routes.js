module.exports = (app) => {
  const userCtrl = require("./controllers/UserController");
  const authCtrl = require("./controllers/AuthController");
  const goalCtrl = require("./controllers/GoalController");
  const jwt = require("jsonwebtoken");

  var router = require("express").Router();

  function verifyToken(req, res, next) {
    let token = req.headers["x-access-token"];

    if (!token) {
      return res.status(401).send({ message: "No token provided!" });
    }

    jwt.verify(token, process.env.JWT_SECRET_KEY, (err, decoded) => {
      if (err) {
        return res.status(401).send({
          message: "Unauthorized!",
        });
      }
      req.user_id = decoded.id;
      next();
    });
  }

  router.get("/", (req, res) => {
    res.json({ message: "Welcome to Goalbook." });
  });

  router.get(
    "/me",
    verifyToken,
    userCtrl.me,
    userCtrl.updateAccountDetails,
    authCtrl.generateJWT,
    authCtrl.returnJWT
  );

  router.post("/users", userCtrl.create);

  router.post(
    "/auth",
    authCtrl.authenticate,
    authCtrl.generateJWT,
    authCtrl.returnJWT
  );

  router.post(
    "/oauth",
    authCtrl.oauth,
    authCtrl.generateJWT,
    authCtrl.returnJWT
  );

  router.get("/goals", verifyToken, goalCtrl.findAll);
  router.post("/goals", verifyToken, goalCtrl.create);
  router.delete("/goals/:id", verifyToken, goalCtrl.destroy);

  app.use("/", router);
};
