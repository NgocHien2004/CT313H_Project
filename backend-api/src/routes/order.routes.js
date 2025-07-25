const express = require("express");
const router = express.Router();
const orderController = require("../controller/order.controller");
const verifyToken = require("../middlewares/verifyToken");
const checkRole = require("../middlewares/checkRole");
const validate = require("../middlewares/validate");
const pagination = require("../middlewares/pagination");
const { createOrderSchema, updateOrderSchema } = require("../schema/order.schema");

// Lấy danh sách đơn hàng
router.get("/", verifyToken, pagination(), orderController.getAllOrders);

// Tạo đơn hàng mới
router.post("/", verifyToken, validate(createOrderSchema), orderController.createOrder);

// Cập nhật thông tin đơn hàng (số bàn, ghi chú)
router.put("/:id", verifyToken, validate(updateOrderSchema), orderController.updateOrder);

// Xoá đơn hàng (chỉ admin)
router.delete("/:id", verifyToken, checkRole("admin"), orderController.deleteOrder);

// Lấy đơn hàng theo ID
router.get("/:id", verifyToken, orderController.getOrderById);

module.exports = router;
