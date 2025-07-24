const express = require("express");
const router = express.Router();
const userController = require("../controller/users.controller");
const verifyToken = require("../middlewares/verifyToken");
const checkRole = require("../middlewares/checkRole");
const validate = require("../middlewares/validate");
const pagination = require("../middlewares/pagination"); 
const { createUserSchema, updateUserSchema } = require("../schema/user.schema");

// Lấy danh sách người dùng
router.get(
  "/",
  verifyToken,
  checkRole("admin"),
  pagination(),
  userController.getAllUsers
); // Thêm pagination() vào đây

// Tạo người dùng mới
router.post(
  "/",
  verifyToken,
  checkRole("admin"),
  validate(createUserSchema),
  userController.createUser
);

// Cập nhật thông tin người dùng
router.put(
  "/:id",
  verifyToken,
  checkRole("admin"),
  validate(updateUserSchema),
  userController.updateUser
);

// Xóa người dùng
router.delete(
  "/:id",
  verifyToken,
  checkRole("admin"),
  userController.deleteUser
);

module.exports = router;
