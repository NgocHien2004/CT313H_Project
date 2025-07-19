const { faker } = require("@faker-js/faker");

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = async function (knex) {
  await knex("categories").del();
  await knex("categories").insert([
    { name: "Món chính", description: "Các món chính" },
    { name: "Đồ uống", description: "Nước giải khát" },
    { name: "Tráng miệng", description: "Món sau bữa chính" },
  ]);
};
