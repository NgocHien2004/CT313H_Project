const { faker } = require("@faker-js/faker/locale/vi");

function createInventoryLog(inventoryId) {
  return {
    inventory_id: inventoryId,
    quantity_added: faker.number.int({ min: 5, max: 50 }),
    note: faker.helpers.arrayElement([
      "Nhập kho nguyên liệu sáng nay",
      "Bổ sung nguyên liệu do thiếu hụt",
      "Hàng mới giao từ nhà cung cấp",
      "Nhập thêm để chuẩn bị cho dịp cuối tuần",
      "Nguyên liệu tươi được nhập vào buổi sáng",
    ]),
    created_at: new Date(),
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.seed = async function (knex) {
  // Xóa toàn bộ log cũ (nếu cần reset)
  await knex("inventory_logs").del();

  // Lấy các inventory chưa bị soft delete
  const inventoryIds = await knex("inventory")
    .where({ is_deleted: false })
    .pluck("id");

  // Tạo 1-3 log cho mỗi nguyên liệu để mô phỏng lịch sử nhập hàng
  const logs = inventoryIds.flatMap((id) => {
    const entries = faker.number.int({ min: 1, max: 3 });
    return Array.from({ length: entries }, () => createInventoryLog(id));
  });

  // Chèn vào bảng logs
  await knex("inventory_logs").insert(logs);
};
