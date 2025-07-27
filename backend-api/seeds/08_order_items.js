const { faker } = require("@faker-js/faker/locale/vi");

function createOrderItem(orderId, dish) {
  const quantity = faker.number.int({ min: 1, max: 3 });
  return {
    order_id: orderId,
    dish_id: dish.id,
    quantity,
    price: dish.price,
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = async function (knex) {
  await knex("order_items").del();
  const orderIds = await knex("orders").pluck("id");
  const dishes = await knex("dishes").select("id", "price");

  if (orderIds.length === 0 || dishes.length === 0) return;

  const items = [];
  for (const orderId of orderIds) {
    const count = faker.number.int({ min: 1, max: 3 });
    const selected = faker.helpers.arrayElements(dishes, count);
    selected.forEach((dish) => {
      items.push(createOrderItem(orderId, dish));
    });
  }

  await knex("order_items").insert(items);

  for (const orderId of orderIds) {
    const rows = await knex("order_items").where("order_id", orderId);
    const total = rows.reduce((sum, r) => sum + r.price * r.quantity, 0);
    await knex("orders").where("id", orderId).update({ total_amount: total });
  }
};
