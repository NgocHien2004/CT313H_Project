const { faker } = require("@faker-js/faker/locale/vi");

/**
 * Danh sách nguyên liệu thực tế cho nhà hàng
 */
const ingredients = [
  "Thịt bò",
  "Thịt gà",
  "Thịt heo",
  "Cá basa",
  "Tôm tươi",
  "Mực lá",
  "Hành lá",
  "Tỏi",
  "Ớt",
  "Gừng",
  "Khoai tây",
  "Cà rốt",
  "Cà chua",
  "Rau xà lách",
  "Rau thơm",
  "Mì trứng",
  "Bún tươi",
  "Nước mắm",
  "Dầu ăn",
  "Đường trắng",
  "Muối",
  "Tiêu đen",
  "Bột ngọt",
  "Bột năng",
  "Bột chiên xù",
];

function createInventory(name) {
  return {
    name,
    quantity: faker.number.int({ min: 10, max: 100 }),
    unit: faker.helpers.arrayElement(["kg", "gói", "chai", "lít", "bó"]),
    is_deleted: false,
    updated_at: new Date(),
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.seed = async function (knex) {
  // Soft delete: đánh dấu tất cả là đã xóa
  await knex("inventory").update({ is_deleted: true });

  // Tạo nguyên liệu mới
  const inventories = ingredients.map((name) => createInventory(name));

  // Thêm vào CSDL
  await knex("inventory").insert(inventories);
};
