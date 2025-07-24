const express = require("express");
const router = express.Router();
const reservationController = require("../controller/reservation.controller");
const validate = require("../middlewares/validate");
const verifyToken = require("../middlewares/verifyToken");
const pagination = require("../middlewares/pagination"); 
const {
  createReservationSchema,
  updateReservationSchema,
} = require("../schema/reservation.schema");

// Lấy tất cả đặt bàn
router.get(
  "/",
  verifyToken,
  pagination(),
  reservationController.getAllReservations
); // Thêm pagination() vào đây

// Tạo đặt bàn
router.post(
  "/",
  verifyToken,
  validate(createReservationSchema),
  reservationController.createReservation
);

// Cập nhật đặt bàn
router.put(
  "/:id",
  verifyToken,
  validate(updateReservationSchema),
  reservationController.updateReservation
);

// Xóa đặt bàn
router.delete("/:id", verifyToken, reservationController.deleteReservation);

module.exports = router;
