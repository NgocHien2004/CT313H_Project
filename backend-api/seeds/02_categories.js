const { faker } = require("@faker-js/faker/locale/vi");

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = async function (knex) {
  // Đánh dấu tất cả category hiện có là đã xoá (soft delete)
  await knex("categories").update({ is_deleted: true });

  // Thêm mới các category mặc định
  await knex("categories").insert([
    { name: "Món chính", description: "Các món chính", is_deleted: false },
    { name: "Đồ uống", description: "Nước giải khát", is_deleted: false },
    {
      name: "Tráng miệng",
      description: "Món sau bữa chính",
      is_deleted: false,
    },
  ]);
};
