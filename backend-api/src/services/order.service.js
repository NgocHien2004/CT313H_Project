const knex = require("../database/knex");
const orderItemService = require("./orderitem.service");

exports.createOrder = async (data) => {
  const [order] = await knex("orders")
    .insert({
      user_id: data.user_id,
      table_number: data.table_number,
      total_amount: 0,
    })
    .returning("*");

  let total = 0;
  for (const item of data.items) {
    const dish = await knex("dishes").where("id", item.dish_id).first();
    if (!dish) throw new Error("Dish not found");

    await knex("order_items").insert({
      order_id: order.id,
      dish_id: item.dish_id,
      quantity: item.quantity,
      price: dish.price,
    });
    total += dish.price * item.quantity;
  }

  await knex("orders").where("id", order.id).update({ total_amount: total });

  return { ...order, total_amount: total };
};

exports.getAllOrders = async ({ limit, offset }) => {
  return await knex("orders").select("*").limit(limit).offset(offset);
};

exports.getOrdersByUser = async ({ userId, limit, offset }) => {
  return await knex("orders")
    .where({ user_id: userId })
    .select("*")
    .limit(limit)
    .offset(offset);
};

exports.updateOrder = async (id, data) => {
  const [order] = await knex("orders")
    .where("id", id)
    .update(data)
    .returning("*");
  return order;
};

exports.deleteOrder = async (id) => {
  return await knex("orders").where("id", id).del();
};

exports.getOrderById = async (orderId) => {
  const order = await knex("orders").where("id", orderId).first();
  if (!order) return null;

  // Gọi hàm mới để lấy danh sách món ăn
  const items = await orderItemService.getOrderItemsByOrderId(orderId);

  order.items = items;

  return order;
};
