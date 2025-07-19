const express = require("express");
const router = express.Router();
const upload = require("../middlewares/upload");
const dishController = require("../controller/dish.controller");
const verifyToken = require("../middlewares/verifyToken");
const checkRole = require("../middlewares/checkRole");
const { createDishSchema, updateDishSchema } = require("../schema/dish.schema");
const pagination = require("../middlewares/pagination"); // Thêm dòng này

// Lấy tất cả món ăn
router.get("/", pagination(), dishController.getAllDishes); // Thêm pagination() vào đây

// Tạo món ăn mới (kèm ảnh)
router.post(
  "/",
  verifyToken,
  checkRole("admin"),
  upload.single("image"),
  dishController.createDish
);

// Cập nhật món ăn (có thể thay ảnh)
router.put(
  "/:id",
  verifyToken,
  checkRole("admin"),
  upload.single("image"),
  dishController.updateDish
);

// Xoá món ăn
router.delete(
  "/:id",
  verifyToken,
  checkRole("admin"),
  dishController.deleteDish
);

module.exports = router;
