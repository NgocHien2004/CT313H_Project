const { faker } = require("@faker-js/faker");

function createDish(categoryIds) {
  return {
    name: faker.commerce.productName(),
    description: faker.commerce.productDescription(),
    price: Number(faker.commerce.price({ min: 20000, max: 100000, dec: 2 })),
    image_url: faker.image.url(),
    category_id: faker.helpers.arrayElement(categoryIds),
    is_available: true,
    created_at: new Date(),
    updated_at: new Date(),
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = async function (knex) {
  await knex("dishes").del();
  const categoryIds = await knex("categories").pluck("id");
  const dishes = Array.from({ length: 15 }, () => createDish(categoryIds));
  await knex("dishes").insert(dishes);
};
