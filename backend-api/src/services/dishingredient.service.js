const knex3 = require("../database/knex");

exports.getDishIngredientsByDishId = async (dish_id) => {
  return await knex3("dish_ingredients").where("dish_id", dish_id);
};

// Lấy danh sách món + nguyên liệu tương ứng
exports.getAllDishesWithIngredients = async () => {
  return await knex3("dishes")
    .select(
      "dishes.id as dish_id",
      "dishes.name as dish_name",
      "ingredients.id as ingredient_id",
      "ingredients.name as ingredient_name"
    )
    .leftJoin("dish_ingredients", "dishes.id", "dish_ingredients.dish_id")
    .leftJoin(
      "ingredients",
      "dish_ingredients.ingredient_id",
      "ingredients.id"
    );
};

exports.createDishIngredient = async (data) => {
  const [inserted] = await knex3("dish_ingredients")
    .insert(data)
    .returning("*");
  return inserted;
};

exports.updateDishIngredient = async (id, data) => {
  const [updated] = await knex3("dish_ingredients")
    .where("id", id)
    .update(data)
    .returning("*");
  return updated;
};

exports.deleteDishIngredient = async (id) => {
  await knex3("dish_ingredients").where("id", id).del();
};
