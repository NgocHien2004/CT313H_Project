const express = require("express");
const router = express.Router();
const dishIngredientController = require("../controller/dishIngredient.controller");
const verifyToken = require("../middlewares/verifyToken");
const checkRole = require("../middlewares/checkRole");
const validate = require("../middlewares/validate");
const {
  createDishIngredientSchema,
  updateDishIngredientSchema,
} = require("../schema/dishingredient.schema");

router.get("/", dishIngredientController.getAllDishIngredients);
router.post(
  "/",
  verifyToken,
  checkRole("admin"),
  validate(createDishIngredientSchema),
  dishIngredientController.createDishIngredient
);
router.put(
  "/:id",
  verifyToken,
  checkRole("admin"),
  validate(updateDishIngredientSchema),
  dishIngredientController.updateDishIngredient
);
router.delete(
  "/:id",
  verifyToken,
  checkRole("admin"),
  dishIngredientController.deleteDishIngredient
);

module.exports = router;
