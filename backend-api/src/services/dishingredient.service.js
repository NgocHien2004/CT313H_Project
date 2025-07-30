const knex3 = require("../database/knex");

exports.getDishIngredientsByDishId = async (dish_id) => {
  return await knex3("dish_ingredients as di")
    .leftJoin("inventory as i", "di.inventory_id", "i.id")
    .leftJoin("dishes as d", "di.dish_id", "d.id")
    .select(
      "di.id",
      "di.dish_id",
      "di.inventory_id",
      "di.quantity_required",
      "i.name as ingredient_name",
      "i.unit as ingredient_unit",
      "i.status as ingredient_status", 
      "d.name as dish_name"
    )
    .where("di.dish_id", dish_id);
};

exports.createDishIngredient = async (data) => {
  const [inserted] = await knex3("dish_ingredients")
    .insert(data)
    .returning("*");
  return inserted;
};

exports.updateDishIngredient = async (id, data) => {
  const [updated] = await knex3("dish_ingredients")
    .where({ id })
    .update(data)
    .returning("*");
  return updated;
};

exports.deleteDishIngredient = async (id) => {
  await knex3("dish_ingredients")
    .where({ id })
    .del();
};
