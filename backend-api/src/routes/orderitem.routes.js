const express = require("express");
const router = express.Router();
const orderItemController = require("../controller/orderitem.controller");
const verifyToken = require("../middlewares/verifyToken");
const checkRole = require("../middlewares/checkRole");

// Lấy order items của một order, chỉ cho phép admin
router.get(
  "/:order_id",
  verifyToken,
  checkRole("admin"),
  orderItemController.getByOrderId
);

module.exports = router;
