const knex = require("../database/knex");
const bcrypt = require("bcrypt");

// CREATE
exports.createUser = async (data) => {
  const exists = await knex("users").where("email", data.email).first();
  if (exists) throw new Error("Email already in use");

  const hashedPassword = await bcrypt.hash(data.password, 10);

  const [user] = await knex("users")
    .insert({ ...data, password: hashedPassword })
    .returning("*");

  return user;
};

// GET ALL (HỖ TRỢ PAGE + OFFSET)
exports.getAllUsers = async ({ page, limit = 10, offset }) => {
  // Nếu dùng offset (web cũ)
  if (offset !== undefined) {
    page = Math.floor(offset / limit) + 1;
  }

  page = page || 1;

  const realOffset = (page - 1) * limit;

  // Lấy data
  const users = await knex("users")
    .select("id", "name", "email", "role")
    .limit(limit)
    .offset(realOffset);

  // Đếm tổng
  const [{ count }] = await knex("users").count("id as count");
  const total = Number(count);

  return {
    data: users,
    page,
    total,
    totalPages: Math.ceil(total / limit),
  };
};

// UPDATE
exports.updateUser = async (id, data) => {
  if (data.password) {
    data.password = await bcrypt.hash(data.password, 10);
  }

  const [user] = await knex("users")
    .where("id", id)
    .update(data)
    .returning(["id", "name", "email", "role"]);

  return user;
};

// DELETE
exports.deleteUser = async (id) => {
  return await knex("users").where("id", id).del();
};