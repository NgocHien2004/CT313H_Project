const knex5 = require("../database/knex");

exports.createInventory = async (data) => {
  const [item] = await knex5("inventory").insert(data).returning("*");
  return item;
};

exports.getAllInventory = async ({ limit, offset }) => {
  return await knex5("inventory").select("*").limit(limit).offset(offset);
};

exports.updateInventory = async (id, data) => {
  const [item] = await knex5("inventory")
    .where("id", id)
    .update(data)
    .returning("*");
  return item;
};

exports.deleteInventory = async (id) => {
  return await knex5("inventory").where("id", id).del();
};
