const rateLimit = require("express-rate-limit");

// Login route — chống brute force
const loginLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 10 phút
  max: 10,
  message: "Bạn đã đăng nhập quá nhiều lần. Vui lòng thử lại sau 5 phút.",
});

// Đặt order (staff gọi món)
const orderLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 phút
  max: 60,
  message: "Bạn đang thao tác gọi món quá nhanh. Vui lòng chờ một chút.",
});

// Đặt bàn / Reservation
const reservationLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 phút
  max: 60,
  message: "Bạn đã gửi quá nhiều yêu cầu đặt bàn. Vui lòng thử lại sau.",
});

// Order item (chi tiết món trong order)
const orderItemLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 100,
  message: "Bạn đang thao tác quá nhiều với món ăn trong đơn hàng.",
});

// Inventory & inventory logs
const inventoryLimiter = rateLimit({
  windowMs: 2 * 60 * 1000,
  max: 100,
  message: "Quá nhiều thao tác liên quan đến kho. Vui lòng đợi một lát.",
});

// Dishes, Categories, Dish Ingredients
const menuLimiter = rateLimit({
  windowMs: 2 * 60 * 1000,
  max: 150,
  message: "Bạn đang cập nhật thực đơn quá nhanh. Vui lòng đợi một chút.",
});

// User (admin thao tác)
const userLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 30,
  message: "Bạn đã thao tác với người dùng quá nhiều. Vui lòng thử lại sau.",
});

// Default limiter (dùng chung cho toàn bộ nếu cần)
const defaultLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 100,
  message: "Bạn gửi quá nhiều yêu cầu. Vui lòng chờ một chút rồi thử lại.",
});

module.exports = {
  loginLimiter,
  orderLimiter,
  reservationLimiter,
  orderItemLimiter,
  inventoryLimiter,
  menuLimiter,
  userLimiter,
  defaultLimiter,
};
