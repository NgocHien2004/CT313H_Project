const knex4 = require("../database/knex");

exports.createDish = async (data) => {
  const [dish] = await knex4("dishes").insert(data).returning("*");
  return dish;
};

exports.getAllDishes = async ({ limit, offset }) => {
  const [totalRow] = await knex4("dishes").count("* as count");
  const total = Number(totalRow.count);
  const data = await knex4("dishes").select("*").limit(limit).offset(offset);
  return { data, total };
};

exports.updateDish = async (id, data) => {
  const [dish] = await knex4("dishes")
    .where("id", id)
    .update(data)
    .returning("*");
  return dish;
};

exports.deleteDish = async (id) => {
  return await knex4("dishes").where("id", id).del();
};
