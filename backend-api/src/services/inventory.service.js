const knex5 = require("../database/knex");

exports.createInventory = async (data) => {
  const [item] = await knex5("inventory").insert(data).returning("*");
  return item;
};

exports.getAllInventory = async ({ page, limit = 10, offset }) => {
  // 🔥 convert offset -> page
  if (offset !== undefined) {
    page = Math.floor(offset / limit) + 1;
  }

  page = page || 1;
  const realOffset = (page - 1) * limit;

  // Get total
  const [{ count }] = await knex5("inventory")
    .where({ is_deleted: false })
    .count("id as count");

  const total = Number(count);

  // Get data
  const data = await knex5("inventory")
    .select("*")
    .where({ is_deleted: false })
    .limit(limit)
    .offset(realOffset);

  return {
    data,
    total,
    page,
    totalPages: Math.ceil(total / limit),
  };
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