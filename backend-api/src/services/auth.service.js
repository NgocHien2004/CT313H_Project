const knex = require("../database/knex");
require("dotenv").config();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

exports.register = async (data) => {
  const { name, email, password } = data;

  const exists = await knex("users").where("email", email).first();
  if (exists) throw new Error("Email already registered");

  const hashedPassword = await bcrypt.hash(password, 10);

  const [user] = await knex("users")
    .insert({
      name,
      email,
      password: hashedPassword,
      role: "user", // Gắn cố định
    })
    .returning(["id", "name", "email", "role"]);

  return user;
};

exports.login = async (data) => {
  const user = await knex("users").where("email", data.email).first();
  if (!user) throw new Error("Invalid credentials");

  const valid = await bcrypt.compare(data.password, user.password);
  if (!valid) throw new Error("Invalid credentials");

  const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: "1d" });

  // Trả về cả token và user info (không bao gồm password)
  return {
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  };
};
