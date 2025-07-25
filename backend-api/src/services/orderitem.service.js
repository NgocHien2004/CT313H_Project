const knex = require("../database/knex");

// Helper function to recalculate order total
const recalculateOrderTotal = async (orderId) => {
  const items = await knex("order_items").where("order_id", orderId);
  const total = items.reduce((sum, item) => sum + item.quantity * item.price, 0);

  await knex("orders").where("id", orderId).update({ total_amount: total });
  return total;
};

// Lấy order items theo order id
exports.getOrderItemsByOrderId = async (orderId) => {
  return await knex("order_items")
    .join("dishes", "order_items.dish_id", "dishes.id")
    .where("order_items.order_id", orderId)
    .select(
      "order_items.id",
      "order_items.order_id",
      "order_items.dish_id",
      "order_items.quantity",
      "order_items.price",
      "dishes.name as dish_name"
    );
};


// Tạo mới 1 order item
exports.createOrderItem = async (data) => {
  const [item] = await knex("order_items").insert(data).returning("*");

  // Recalculate order total
  await recalculateOrderTotal(item.order_id);

  return item;
};

// Cập nhật order item theo id
exports.updateOrderItem = async (id, data) => {
  // Get the order item first to know which order to update
  const existingItem = await knex("order_items").where("id", id).first();
  if (!existingItem) {
    return null;
  }

  const [updated] = await knex("order_items").where("id", id).update(data).returning("*");

  // Recalculate order total
  await recalculateOrderTotal(existingItem.order_id);

  return updated;
};

// Xoá order item theo id
exports.deleteOrderItem = async (id) => {
  // Get the order item first to know which order to update
  const existingItem = await knex("order_items").where("id", id).first();
  if (!existingItem) {
    return false;
  }

  const deletedCount = await knex("order_items").where("id", id).del();

  if (deletedCount > 0) {
    // Recalculate order total
    await recalculateOrderTotal(existingItem.order_id);
  }

  return deletedCount > 0;
};
