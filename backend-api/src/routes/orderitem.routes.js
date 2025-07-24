const express = require("express");
const router = express.Router();
const orderItemController = require("../controller/orderitem.controller");
const verifyToken = require("../middlewares/verifyToken");
const checkRole = require("../middlewares/checkRole");
const validate = require("../middlewares/validate");
const {
  createOrderItemSchema,
  updateOrderItemSchema,
} = require("../schema/orderitem.schema");

// GET all order items (admin only)
router.get("/", verifyToken, orderItemController.getAll);

// POST create new order item
router.post(
  "/",
  verifyToken,
  checkRole("admin"),
  validate(createOrderItemSchema),
  orderItemController.create
);

// PUT update order item by id
router.put(
  "/:id",
  verifyToken,
  checkRole("admin"),
  validate(updateOrderItemSchema),
  orderItemController.update
);

// DELETE order item by id
router.delete(
  "/:id",
  verifyToken,
  checkRole("admin"),
  orderItemController.remove
);

module.exports = router;
