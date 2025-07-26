const knex3 = require("../database/knex");

exports.getDishIngredientsByDishId = async (dish_id) => {
  return await knex3("dish_ingredients").where("dish_id", dish_id);
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
