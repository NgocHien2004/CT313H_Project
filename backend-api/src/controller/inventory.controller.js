const inventoryService = require("../services/inventory.service");

exports.createInventory = async (req, res, next) => {
  try {
    const item = await inventoryService.createInventory(req.body);
    res.status(201).json({ message: "Inventory item added", data: item });
  } catch (err) {
    next(err);
  }
};

exports.getAllInventory = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination || {
      page: 1,
      limit: 10,
      offset: 0,
    };
    const inventory = await inventoryService.getAllInventory({ limit, offset });
    res.json({ data: inventory, page, limit });
  } catch (err) {
    next(err);
  }
};

exports.updateInventory = async (req, res, next) => {
  try {
    const item = await inventoryService.updateInventory(
      req.params.id,
      req.body
    );
    res.json({ message: "Inventory item updated", data: item });
  } catch (err) {
    next(err);
  }
};

exports.deleteInventory = async (req, res, next) => {
  try {
    await inventoryService.deleteInventory(req.params.id);
    res.json({ message: "Inventory item deleted" });
  } catch (err) {
    next(err);
  }
};
