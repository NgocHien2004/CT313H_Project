const { faker } = require("@faker-js/faker/locale/vi"); // Dùng locale tiếng Việt

const dishList = [
  {
    name: "Phở bò",
    description: "Nước dùng đậm đà, bánh phở mềm, thịt bò thơm ngon.",
  },
  {
    name: "Cơm tấm",
    description: "Sườn nướng, bì, chả ăn kèm cơm tấm đặc trưng miền Nam.",
  },
  {
    name: "Bún chả",
    description: "Thịt nướng đậm vị ăn kèm bún và nước mắm chua ngọt.",
  },
  {
    name: "Gỏi cuốn",
    description: "Cuốn tươi với tôm, thịt, rau sống và nước chấm đậu phộng.",
  },
  {
    name: "Chả giò",
    description: "Chả giò chiên giòn rụm, nhân thịt và miến thơm ngon.",
  },
  { name: "Bánh xèo", description: "Vỏ bánh vàng giòn với tôm, thịt, giá đỗ." },
  { name: "Hủ tiếu", description: "Sợi hủ tiếu dai, nước dùng thanh ngọt." },
  {
    name: "Xôi gà",
    description: "Xôi nếp dẻo ăn kèm thịt gà luộc và nước mắm gừng.",
  },
  {
    name: "Canh chua cá",
    description: "Canh chua thanh mát với cá, cà chua, bạc hà và me.",
  },
  {
    name: "Lẩu hải sản",
    description: "Tôm, mực, nghêu và rau tươi trong nước lẩu cay nồng.",
  },
];

function createDish(categoryIds, index) {
  const item = dishList[index % dishList.length];
  return {
    name: item.name,
    description: item.description,
    price: faker.number.int({ min: 30000, max: 150000 }),
    image_url: faker.image.urlLoremFlickr({ category: "food" }),
    category_id: faker.helpers.arrayElement(categoryIds),
    is_deleted: false,
    created_at: new Date(),
    updated_at: new Date(),
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.seed = async function (knex) {
  // Đánh dấu các món cũ là đã xóa (soft delete)
  await knex("dishes").update({ is_deleted: true });

  // Lấy các danh mục chưa bị xóa
  const categoryIds = await knex("categories")
    .where({ is_deleted: false })
    .pluck("id");

  // Tạo 15 món ăn mới (lặp lại danh sách nếu cần)
  const dishes = Array.from({ length: 15 }, (_, i) =>
    createDish(categoryIds, i)
  );

  // Thêm món ăn vào cơ sở dữ liệu
  await knex("dishes").insert(dishes);
};
