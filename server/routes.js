module.exports = app => {
  const userCtrl = require("./controllers/UserController");
  const authCtrl = require("./controllers/AuthController");
  const goalCtrl = require("./controllers/GoalController");

  var router = require("express").Router();

  router.post("/users", userCtrl.create);

  router.post(
    "/auth",
    authCtrl.authenticate,
    authCtrl.generateJWT,
    authCtrl.returnJWT
  );

  router.get("/goals", goalCtrl.findAll);
  router.post("/goals", goalCtrl.create);

  app.use("/", router);
};
