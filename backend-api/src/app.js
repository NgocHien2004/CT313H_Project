const express = require("express");
const cors = require("cors");
const path = require("path");
const errorHandler = require("./middlewares/errorHandler");

const app = express();
require("dotenv").config();

app.use(cors());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
//app.use("/uploads", express.static("public/uploads"));

// Serve ảnh tĩnh từ thư mục uploads
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

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/dishes", dishRoutes);
app.use("/api/dish-ingredients", dishIngredientRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/order-items", orderItemRoutes);
app.use("/api/inventory", inventoryRoutes);
app.use("/api/inventory-logs", inventoryLogRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/reservations", reservationRoutes);

// 404 fallback
app.use((req, res, next) => {
  res.status(404).json({ message: "API route not found" });
});

// Global error handler
app.use(errorHandler);

module.exports = app;
