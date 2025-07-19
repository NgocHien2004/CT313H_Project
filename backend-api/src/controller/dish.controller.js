const dishService = require("../services/dish.service");

exports.createDish = async (req, res, next) => {
  try {
    console.log("=== DEBUG DISH UPLOAD ===");
    console.log("Headers:", req.headers["content-type"]);
    console.log("req.body:", req.body);
    console.log("req.file:", req.file);

    const image_url = req.file ? `/uploads/${req.file.filename}` : null;
    const data = { ...req.body, image_url };
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
    const result = await dishService.getAllDishes({ limit, offset });
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
    const image_url = req.file ? `/uploads/${req.file.filename}` : undefined;
    const data = { ...req.body };
    if (image_url) data.image_url = image_url;
    const dish = await dishService.updateDish(req.params.id, data);
    res.json({ message: "Dish updated", data: dish });
  } catch (err) {
    next(err);
  }
};

exports.deleteDish = async (req, res, next) => {
  try {
    await dishService.deleteDish(req.params.id);
    res.json({ message: "Dish deleted" });
  } catch (err) {
    next(err);
  }
};
