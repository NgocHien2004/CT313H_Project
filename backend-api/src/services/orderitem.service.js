const knex = require("../database/knex");

exports.getByOrderId = async (orderId) => {
  return await knex("order_items")
    .where("order_id", orderId)
    .join("dishes", "order_items.dish_id", "dishes.id")
    .select(
      "order_items.dish_id",
      "order_items.order_id",
      "dishes.name",
      "order_items.quantity",
      "order_items.price"
    );
};
