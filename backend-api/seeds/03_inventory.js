const { faker } = require("@faker-js/faker");

function createInventory() {
  return {
    name: faker.commerce.productMaterial(),
    quantity: faker.number.int({ min: 10, max: 100 }),
    unit: faker.helpers.arrayElement(["kg", "g", "lít", "ml", "cái"]),
    min_quantity: faker.number.int({ min: 5, max: 20 }),
    updated_at: new Date(),
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = async function (knex) {
  await knex("inventory").del();
  const inventory = Array.from({ length: 10 }, createInventory);
  await knex("inventory").insert(inventory);
};
