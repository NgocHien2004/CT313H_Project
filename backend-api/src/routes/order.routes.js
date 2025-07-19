const express = require("express");
const router = express.Router();
const orderController = require("../controller/order.controller");
const verifyToken = require("../middlewares/verifyToken");
const checkRole = require("../middlewares/checkRole");
const validate = require("../middlewares/validate");
const pagination = require("../middlewares/pagination"); // Thêm dòng này
const {
  createOrderSchema,
  updateOrderSchema,
} = require("../schema/order.schema");

// Lấy danh sách đơn hàng
router.get("/", verifyToken, pagination(), orderController.getAllOrders);

// Tạo đơn hàng mới
router.post(
  "/",
  verifyToken,
  validate(createOrderSchema),
  orderController.createOrder
);

// Cập nhật thông tin đơn hàng (số bàn, ghi chú (chỉ admin))
router.put(
  "/:id",
  verifyToken,
  checkRole("admin"),
  validate(updateOrderSchema),
  orderController.updateOrder
);

// Xoá đơn hàng (chỉ admin)
router.delete(
  "/:id",
  verifyToken,
  checkRole("admin"),
  orderController.deleteOrder
);

// Cập nhật toàn bộ món ăn trong đơn hàng (chỉ admin)
router.put(
  "/:id/items",
  verifyToken,
  checkRole("admin"),
  orderController.updateOrderItems
);

module.exports = router;
