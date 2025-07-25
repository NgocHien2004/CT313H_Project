const dishIngredientService = require("../services/dishingredient.service");

exports.getDishIngredientsByDishId = async (req, res, next) => {
  try {
    const dishId = req.params.dishId;
    const ingredients =
      await dishIngredientService.getDishIngredientsByDishId(dishId);
    res.json(ingredients);
  } catch (err) {
    next(err);
  }
};

exports.getAllDishesWithIngredients = async (req, res, next) => {
  try {
    const data = await dishIngredientService.getAllDishesWithIngredients();
    res.json({ data });
  } catch (err) {
    next(err);
  }
};

exports.createDishIngredient = async (req, res, next) => {
  try {
    const result = await dishIngredientService.createDishIngredient(req.body);
    res.status(201).json({ message: "Dish ingredient added", data: result });
  } catch (err) {
    next(err);
  }
};

exports.updateDishIngredient = async (req, res, next) => {
  try {
    const updated = await dishIngredientService.updateDishIngredient(
      req.params.id,
      req.body
    );
    res.json({ message: "Dish ingredient updated", data: updated });
  } catch (err) {
    next(err);
  }
};

exports.deleteDishIngredient = async (req, res, next) => {
  try {
    await dishIngredientService.deleteDishIngredient(req.params.id);
    res.json({ message: "Dish ingredient deleted" });
  } catch (err) {
    next(err);
  }
};
