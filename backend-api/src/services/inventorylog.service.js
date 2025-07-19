const knex2 = require("../database/knex");

exports.createInventoryLog = async (data) => {
  const [log] = await knex2("inventory_logs").insert(data).returning("*");
  return log;
};

exports.getAllInventoryLogs = async ({ limit, offset }) => {
  return await knex2("inventory_logs").select("*").limit(limit).offset(offset);
};
