const express = require("express");
const router = express.Router();
const inventoryController = require("../controller/inventory.controller");
const checkRole = require("../middlewares/checkRole");
const verifyToken = require("../middlewares/verifyToken");
const validate = require("../middlewares/validate");
const pagination = require("../middlewares/pagination"); // Thêm dòng này
const {
  createInventorySchema,
  updateInventorySchema,
} = require("../schema/inventory.schema");

// Lấy danh sách nguyên liệu tồn kho
router.get("/", pagination(), inventoryController.getAllInventory); // Thêm pagination() vào đây

// Tạo mới nguyên liệu
router.post(
  "/",
  verifyToken,
  checkRole("admin"),
  validate(createInventorySchema),
  inventoryController.createInventory
);

// Cập nhật nguyên liệu
router.put(
  "/:id",
  verifyToken,
  checkRole("admin"),
  validate(updateInventorySchema),
  inventoryController.updateInventory
);

// Xóa nguyên liệu
router.delete(
  "/:id",
  verifyToken,
  checkRole("admin"),
  inventoryController.deleteInventory
);

module.exports = router;
