const dishService = require("../services/dish.service");

// Helper function to convert string boolean to actual boolean
const convertStringBoolean = (value) => {
  if (typeof value === "boolean") return value;
  if (typeof value === "string") {
    return value.toLowerCase() === "true";
  }
  return Boolean(value);
};

exports.createDish = async (req, res, next) => {
  try {
    console.log("=== DEBUG DISH UPLOAD ===");
    console.log("Headers:", req.headers["content-type"]);
    console.log("req.body:", req.body);
    console.log("req.file:", req.file);

    const image_url = req.file ? `/uploads/${req.file.filename}` : null;

    // Xử lý dữ liệu và convert boolean
    const data = {
      ...req.body,
      image_url,
      // Convert string boolean từ FormData thành actual boolean
      is_available:
        req.body.is_available !== undefined
          ? convertStringBoolean(req.body.is_available)
          : true,
    };

    console.log("Processed data:", data);

    const dish = await dishService.createDish(data);
    res.status(201).json({ message: "Dish created", data: dish });
  } catch (err) {
    next(err);
  }
};

exports.getAllDishes = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination || {
      page: 1,
      limit: 10,
      offset: 0,
    };

    // Lấy search parameters từ query
    const filters = {
      search: req.query.search,
      category_id: req.query.category_id,
      is_available: req.query.is_available,
    };

    const result = await dishService.getAllDishes({ limit, offset, filters });
    res.json({
      data: result.data,
      total: result.total,
      page,
      limit,
    });
  } catch (err) {
    next(err);
  }
};

exports.updateDish = async (req, res, next) => {
  try {
    console.log("=== DEBUG DISH UPDATE ===");
    console.log("Headers:", req.headers["content-type"]);
    console.log("req.body:", req.body);
    console.log("req.file:", req.file);

    const image_url = req.file ? `/uploads/${req.file.filename}` : undefined;

    // Xử lý dữ liệu và convert boolean
    const data = { ...req.body };
    if (image_url) data.image_url = image_url;

    // Convert string boolean từ FormData thành actual boolean
    if (data.is_available !== undefined) {
      data.is_available = convertStringBoolean(data.is_available);
    }

    console.log("Processed update data:", data);

    const dish = await dishService.updateDish(req.params.id, data);
    res.json({ message: "Dish updated", data: dish });
  } catch (err) {
    next(err);
  }
};

exports.deleteDish = async (req, res, next) => {
  try {
    const result = await dishService.deleteDish(req.params.id);

    // Handle both soft delete and hard delete responses
    if (result && result.success) {
      res.json({
        message: result.message,
        data: result.data || { deleted: result.deleted },
      });
    } else {
      res.json({ message: "Dish deleted" });
    }
  } catch (err) {
    if (err.message === "Dish not found") {
      return res.status(404).json({ message: "Dish not found" });
    }
    if (err.message.includes("Cannot delete dish")) {
      return res.status(400).json({ message: err.message });
    }
    next(err);
  }
};

exports.getDishWithIngredientsById = async (req, res) => {
  try {
    const dishId = req.params.id;
    const dish = await dishService.getDishWithIngredientsById(dishId);

    if (!dish) {
      return res.status(404).json({ message: "Món ăn không tồn tại" });
    }

    res.json(dish);
  } catch (error) {
    console.error("Lỗi khi lấy chi tiết món ăn:", error);
    res.status(500).json({ message: "Lỗi server", error });
  }
};
