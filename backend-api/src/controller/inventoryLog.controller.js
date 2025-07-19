const inventoryLogService = require("../services/inventorylog.service");

exports.createInventoryLog = async (req, res, next) => {
  try {
    const log = await inventoryLogService.createInventoryLog(req.body);
    res.status(201).json({ message: "Inventory log created", data: log });
  } catch (err) {
    next(err);
  }
};

exports.getAllInventoryLogs = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination || {
      page: 1,
      limit: 10,
      offset: 0,
    };
    const logs = await inventoryLogService.getAllInventoryLogs({
      limit,
      offset,
    });
    res.json({ data: logs, page, limit });
  } catch (err) {
    next(err);
  }
};
