const knex = require("../database/knex");

// Lấy tất cả order items
exports.getAllOrderItems = async () => {
  return await knex("order_items")
    .join("dishes", "order_items.dish_id", "dishes.id")
    .select(
      "order_items.id",
      "order_items.order_id",
      "order_items.dish_id",
      "dishes.name",
      "order_items.quantity",
      "order_items.price"
    );
};

// Tạo mới 1 order item
exports.createOrderItem = async (data) => {
  const [item] = await knex("order_items").insert(data).returning("*");
  return item;
};

// Cập nhật order item theo id
exports.updateOrderItem = async (id, data) => {
  const [updated] = await knex("order_items")
    .where("id", id)
    .update(data)
    .returning("*");
  return updated;
};

// Xoá order item theo id
exports.deleteOrderItem = async (id) => {
  return await knex("order_items").where("id", id).del();
};
