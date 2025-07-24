const knex = require("../database/knex");

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
  return await knex("orders").where({ user_id: userId }).select("*").limit(limit).offset(offset);
};

exports.updateOrder = async (id, data) => {
  const [order] = await knex("orders").where("id", id).update(data).returning("*");
  return order;
};

exports.deleteOrder = async (id) => {
  return await knex("orders").where("id", id).del();
};

exports.updateOrderItems = async (orderId, items) => {
  await knex("order_items").where("order_id", orderId).del();

  const dishes = await knex("dishes").select("id", "price");
  const dishMap = Object.fromEntries(dishes.map((d) => [d.id, d.price]));

  const newItems = items.map((item) => ({
    order_id: orderId,
    dish_id: item.dish_id,
    quantity: item.quantity,
    price: dishMap[item.dish_id] || 0,
  }));

  await knex("order_items").insert(newItems);

  const total = newItems.reduce((sum, i) => sum + i.quantity * i.price, 0);
  const [updatedOrder] = await knex("orders").where("id", orderId).update({ total_amount: total }).returning("*");

  return updatedOrder;
};
