const service = require("../services/orderitem.service");

exports.getByOrderId = async (req, res, next) => {
  try {
    const data = await service.getByOrderId(req.params.order_id);
    res.json({ data });
  } catch (err) {
    next(err);
  }
};
