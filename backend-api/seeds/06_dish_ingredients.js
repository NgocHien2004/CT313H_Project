const { faker } = require("@faker-js/faker");

function createDishIngredient(dishId, inventoryIds) {
  return {
    dish_id: dishId,
    inventory_id: faker.helpers.arrayElement(inventoryIds),
    quantity_required: faker.number.int({ min: 1, max: 5 }),
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = async function (knex) {
  await knex("dish_ingredients").del();
  const dishIds = await knex("dishes").pluck("id");
  const inventoryIds = await knex("inventory").pluck("id");

  const ingredients = [];
  dishIds.forEach((dishId) => {
    const count = faker.number.int({ min: 1, max: 3 });
    for (let i = 0; i < count; i++) {
      ingredients.push(createDishIngredient(dishId, inventoryIds));
    }
  });

  await knex("dish_ingredients").insert(ingredients);
};
