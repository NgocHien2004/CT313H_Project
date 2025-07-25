const express = require("express");
const router = express.Router();
const orderItemController = require("../controller/orderitem.controller");
const verifyToken = require("../middlewares/verifyToken");
const validate = require("../middlewares/validate");
const { createOrderItemSchema, updateOrderItemSchema } = require("../schema/orderitem.schema");

// GET all order items 
router.get("/order/:orderId", verifyToken, orderItemController.getByOrderId);

// POST create new order item 
router.post("/", verifyToken, validate(createOrderItemSchema), orderItemController.create);

// PUT update order item by id - UPDATED: Allow regular users
router.put("/:id", verifyToken, validate(updateOrderItemSchema), orderItemController.update);

// DELETE order item by id - UPDATED: Allow regular users
router.delete("/:id", verifyToken, orderItemController.remove);

module.exports = router;
