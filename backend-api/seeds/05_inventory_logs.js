const { faker } = require("@faker-js/faker");

function createInventoryLog(inventoryId) {
  return {
    inventory_id: inventoryId,
    quantity_added: faker.number.int({ min: 10, max: 50 }),
    note: faker.lorem.sentence(),
    created_at: new Date(),
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = async function (knex) {
  await knex("inventory_logs").del();
  const inventoryIds = await knex("inventory").pluck("id");
  const logs = inventoryIds.map((id) => createInventoryLog(id));
  await knex("inventory_logs").insert(logs);
};
