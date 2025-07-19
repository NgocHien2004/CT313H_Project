const { faker } = require("@faker-js/faker");

function createUser() {
  return {
    name: faker.person.fullName(),
    email: faker.internet.email(),
    password: faker.internet.password(),
    role: faker.helpers.arrayElement(["user", "admin"]),
    created_at: new Date(),
    updated_at: new Date(),
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = async function (knex) {
  await knex("users").del();
  const users = Array.from({ length: 10 }, createUser);
  await knex("users").insert(users);
};
