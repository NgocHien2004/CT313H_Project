const knex2 = require("../database/knex");

exports.createInventoryLog = async (data) => {
  const [log] = await knex2("inventory_logs").insert(data).returning("*");
  return log;
};

exports.getAllInventoryLogs = async ({ page, limit = 10, offset }) => {
  if (offset !== undefined) {
    page = Math.floor(offset / limit) + 1;
  }

  page = page || 1;
  const realOffset = (page - 1) * limit;

  // Get total
  const [{ count }] = await knex2("inventory_logs").count("id as count");
  const total = Number(count);

  // Get data
  const data = await knex2("inventory_logs")
    .select("*")
    .orderBy("created_at", "desc")
    .limit(limit)
    .offset(realOffset);

  return {
    data,
    total,
    page,
    totalPages: Math.ceil(total / limit),
  };
};