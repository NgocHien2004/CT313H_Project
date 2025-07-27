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

exports.getAllOrders = async ({ limit, offset, filters = {} }) => {
  // Build query với filters
  let query = knex("orders").select("*");
  let countQuery = knex("orders");

  // Apply filters
  if (filters.status) {
    query = query.where("status", filters.status);
    countQuery = countQuery.where("status", filters.status);
  }

  if (filters.table_number) {
    query = query.where("table_number", filters.table_number);
    countQuery = countQuery.where("table_number", filters.table_number);
  }

  if (filters.date) {
    // Filter by date (created_at)
    const startDate = new Date(filters.date);
    const endDate = new Date(filters.date);
    endDate.setDate(endDate.getDate() + 1); // Next day

    query = query.whereBetween("created_at", [startDate, endDate]);
    countQuery = countQuery.whereBetween("created_at", [startDate, endDate]);
  }

  // Get total count
  const [totalRow] = await countQuery.count("* as count");
  const total = Number(totalRow.count);

  // Get data with pagination
  const data = await query.orderBy("created_at", "desc").limit(limit).offset(offset);

  return { data, total };
};

exports.getOrdersByUser = async ({ userId, limit, offset, filters = {} }) => {
  // Build query với filters cho user cụ thể
  let query = knex("orders").where({ user_id: userId }).select("*");
  let countQuery = knex("orders").where({ user_id: userId });

  // Apply filters
  if (filters.status) {
    query = query.where("status", filters.status);
    countQuery = countQuery.where("status", filters.status);
  }

  if (filters.table_number) {
    query = query.where("table_number", filters.table_number);
    countQuery = countQuery.where("table_number", filters.table_number);
  }

  if (filters.date) {
    // Filter by date (created_at)
    const startDate = new Date(filters.date);
    const endDate = new Date(filters.date);
    endDate.setDate(endDate.getDate() + 1); // Next day

    query = query.whereBetween("created_at", [startDate, endDate]);
    countQuery = countQuery.whereBetween("created_at", [startDate, endDate]);
  }

  // Get total count
  const [totalRow] = await countQuery.count("* as count");
  const total = Number(totalRow.count);

  // Get data with pagination
  const data = await query.orderBy("created_at", "desc").limit(limit).offset(offset);

  return { data, total };
};

exports.updateOrder = async (id, data) => {
  const [order] = await knex("orders").where("id", id).update(data).returning("*");
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
