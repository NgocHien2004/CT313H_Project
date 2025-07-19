const knex = require("../database/knex");

exports.getAllCategories = async () => {
  return await knex("categories").select();
};

exports.createCategory = async (data) => {
  const [category] = await knex("categories").insert(data).returning("*");
  return category;
};

exports.updateCategory = async (id, data) => {
  const [updated] = await knex("categories")
    .where("id", id)
    .update(data)
    .returning("*");
  return updated;
};

exports.deleteCategory = async (id) => {
  await knex("categories").where("id", id).del();
};
