const dishIngredientService = require("../services/dishingredient.service");

exports.getAllDishIngredients = async (req, res, next) => {
  try {
    const list = await dishIngredientService.getAllDishIngredients();
    res.json(list);
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
