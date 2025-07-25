const knex4 = require("../database/knex");
const dishIngredientService = require("./dishingredient.service");

exports.createDish = async (data) => {
  const [dish] = await knex4("dishes").insert(data).returning("*");
  return dish;
};

exports.getAllDishes = async ({ limit, offset, filters = {} }) => {
  // Build query với filters
  let query = knex4("dishes").select("*");
  let countQuery = knex4("dishes");

  // Apply filters
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

  // Get total count
  const [totalRow] = await countQuery.count("* as count");
  const total = Number(totalRow.count);

  // Get data with pagination
  const data = await query
    .orderBy("created_at", "desc")
    .limit(limit)
    .offset(offset);

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

exports.getDishWithIngredientsById = async (dishId) => {
  // Lấy món ăn theo ID
  const dish = await knex4("dishes").where("id", dishId).first();

  if (!dish) {
    return null;
  }

  // Lấy nguyên liệu của món ăn
  const ingredients =
    await dishIngredientService.getDishIngredientsByDishId(dishId);

  // Gắn nguyên liệu vào dish
  return {
    ...dish,
    ingredients,
  };
};
