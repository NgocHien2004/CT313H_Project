const { faker } = require("@faker-js/faker/locale/vi");

function createUser() {
  return {
    name: faker.person.fullName(),
    email: faker.internet.email(),
    password: faker.internet.password(),
    role: faker.helpers.arrayElement(["user", "admin"]),
    is_deleted: false, // quan trọng!
    created_at: new Date(),
    updated_at: new Date(),
  };
}

exports.seed = async function (knex) {
  // Soft delete: đánh dấu tất cả user là đã bị xoá
  await knex("users").update({ is_deleted: true });

  // Tạo danh sách user mới
  const users = Array.from({ length: 10 }, createUser);

  // Thêm hoặc cập nhật user
  await knex("users")
    .insert(users)
    .onConflict("email") // tránh trùng email
    .merge(); // cập nhật nếu email trùng
};
