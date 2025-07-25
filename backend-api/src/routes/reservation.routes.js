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

// Label tiếng Việt cho các field đặt bàn
const reservationFieldLabels = {
  customer_name: "Tên khách hàng",
  phone_number: "Số điện thoại",
  number_of_guests: "Số lượng khách",
  reservation_time: "Thời gian đặt bàn",
  note: "Ghi chú",
  status: "Trạng thái",
};

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
  validate(createReservationSchema, { fieldLabels: reservationFieldLabels }),
  reservationController.createReservation
);

// Cập nhật đặt bàn
router.put(
  "/:id",
  verifyToken,
  validate(updateReservationSchema, { fieldLabels: reservationFieldLabels }),
  reservationController.updateReservation
);

// Xóa đặt bàn
router.delete("/:id", verifyToken, reservationController.deleteReservation);

module.exports = router;
