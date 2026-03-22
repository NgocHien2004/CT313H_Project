const knex4 = require("../database/knex");
const dishIngredientService = require("./dishingredient.service");

exports.createDish = async (data) => {
  const [dish] = await knex4("dishes").insert(data).returning("*");
  return dish;
};

exports.getAllDishes = async ({
  page,
  limit = 10,
  offset,
  filters = {},
}) => {
  if (offset !== undefined) {
    page = Math.floor(offset / limit) + 1;
  }

  page = page || 1;
  const realOffset = (page - 1) * limit;

  let query = knex4("dishes").select("*");
  let countQuery = knex4("dishes");

  // FILTERS
  if (filters.search) {
    const searchPattern = `%${filters.search}%`;
    query = query.where("name", "ilike", searchPattern);
    countQuery = countQuery.where("name", "ilike", searchPattern);
  }

  if (filters.category_id) {
    query = query.where("category_id", filters.category_id);
    countQuery = countQuery.where("category_id", filters.category_id);
  }

  if (filters.is_available !== undefined && filters.is_available !== "") {
    const isAvailable = filters.is_available === "true";
    query = query.where("is_available", isAvailable);
    countQuery = countQuery.where("is_available", isAvailable);
  }

  // TOTAL 
  const [{ count }] = await countQuery.count("id as count");
  const total = Number(count);

  // DATA 
  const data = await query
    .orderBy("created_at", "desc")
    .limit(limit)
    .offset(realOffset);

  return {
    data,
    page,
    total,
    totalPages: Math.ceil(total / limit),
  };
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

exports.getDishWithIngredientsById = async (dishId) => {
  const dish = await knex4("dishes").where("id", dishId).first();

  if (!dish) return null;

  const ingredients =
    await dishIngredientService.getDishIngredientsByDishId(dishId);

  return {
    ...dish,
    ingredients,
  };
};