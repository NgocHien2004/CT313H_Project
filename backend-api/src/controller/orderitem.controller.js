const service = require("../services/orderitem.service");

// Lấy tất cả order items
exports.getAll = async (req, res, next) => {
  try {
    const data = await service.getAllOrderItems();
    res.json({ data });
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const data = req.body;
    const item = await service.createOrderItem(data);
    res.status(201).json({
      message: "Order item created",
      data: item,
    });
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const id = req.params.id;
    const data = req.body;
    const updated = await service.updateOrderItem(id, data);
    if (!updated) {
      return res.status(404).json({ message: "Order item not found" });
    }
    res.json({
      message: "Order item updated",
      data: updated,
    });
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const id = req.params.id;
    const deleted = await service.deleteOrderItem(id);
    if (!deleted) {
      return res.status(404).json({ message: "Order item not found" });
    }
    res.json({ message: "Order item deleted" });
  } catch (err) {
    next(err);
  }
};
