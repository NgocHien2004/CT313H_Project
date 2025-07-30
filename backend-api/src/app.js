const express = require("express");
const cors = require("cors");
// const path = require("path");
const errorHandler = require("./middlewares/errorHandler");
const {
  loginLimiter,
  orderLimiter,
  reservationLimiter,
  orderItemLimiter,
  inventoryLimiter,
  menuLimiter,
  userLimiter,
  // defaultLimiter,
} = require("./middlewares/RateLimit");

const app = express();
require("dotenv").config();

app.use(cors());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
//app.use("/uploads", express.static("public/uploads"));
//app.use("/uploads", express.static(path.join(__dirname, "../public/uploads")));

// Swagger docs
const swaggerRoutes = require("./routes/swagger");
app.use("/api-docs", swaggerRoutes);

// API routes
const authRoutes = require("./routes/auth.routes");
const userRoutes = require("./routes/user.routes");
const dishRoutes = require("./routes/dish.routes");
const dishIngredientRoutes = require("./routes/dishIngredient.routes");
const orderRoutes = require("./routes/order.routes");
const orderItemRoutes = require("./routes/orderitem.routes");
const inventoryRoutes = require("./routes/inventory.routes");
const inventoryLogRoutes = require("./routes/inventoryLog.routes");
const categoryRoutes = require("./routes/category.routes");
const reservationRoutes = require("./routes/reservation.routes");

// Gắn rate limit cho từng nhóm route
app.use("/api/auth", loginLimiter, authRoutes);
app.use("/api/users", userLimiter, userRoutes);
app.use("/api/dishes", menuLimiter, dishRoutes);
app.use("/api/dish-ingredients", menuLimiter, dishIngredientRoutes);
app.use("/api/orders", orderLimiter, orderRoutes);
app.use("/api/order-items", orderItemLimiter, orderItemRoutes);
app.use("/api/inventory", inventoryLimiter, inventoryRoutes);
app.use("/api/inventory-logs", inventoryLimiter, inventoryLogRoutes);
app.use("/api/categories", menuLimiter, categoryRoutes);
app.use("/api/reservations", reservationLimiter, reservationRoutes);

// 404 fallback
app.use((req, res, next) => {
  res.status(404).json({ message: "Không tìm thấy route API." });
});

// Global error handler
app.use(errorHandler);

module.exports = app;
