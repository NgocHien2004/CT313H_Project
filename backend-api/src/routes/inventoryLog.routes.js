const express = require("express");
const router = express.Router();
const controller = require("../controller/inventoryLog.controller");
const { createInventoryLogSchema } = require("../schema/inventorylog.schema");
const validate = require("../middlewares/validate");
const verifyToken = require("../middlewares/verifyToken");
const checkRole = require("../middlewares/checkRole");
const pagination = require("../middlewares/pagination"); 

router.get("/", verifyToken, pagination(), controller.getAllInventoryLogs); // Thêm pagination() vào đây
router.post(
  "/",
  verifyToken,
  checkRole("admin"),
  validate(createInventoryLogSchema),
  controller.createInventoryLog
);

module.exports = router;
