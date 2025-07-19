const { faker } = require("@faker-js/faker");

function createOrder(userIds) {
  return {
    user_id: faker.helpers.arrayElement(userIds),
    table_number: faker.number.int({ min: 1, max: 20 }),
    total_amount: 0,
    status: faker.helpers.arrayElement(["pending", "completed"]),
    created_at: new Date(),
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = async function (knex) {
  await knex("orders").del();
  const userIds = await knex("users").pluck("id");
  const orders = Array.from({ length: 10 }, () => createOrder(userIds));
  await knex("orders").insert(orders);
};
