const orderService = require("../services/order.service");

exports.createOrder = async (req, res, next) => {
  try {
    const order = await orderService.createOrder(req.body);
    res.status(201).json({ message: "Order created", data: order });
  } catch (err) {
    next(err);
  }
};

exports.getAllOrders = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination || {
      page: 1,
      limit: 10,
      offset: 0,
    };
    let orders;
    if (req.user.role === "admin") {
      orders = await orderService.getAllOrders({ limit, offset });
    } else {
      orders = await orderService.getOrdersByUser({
        userId: req.user.id,
        limit,
        offset,
      });
    }
    res.json({ data: orders, page, limit });
  } catch (err) {
    next(err);
  }
};

exports.updateOrder = async (req, res, next) => {
  try {
    const order = await orderService.updateOrder(req.params.id, req.body);
    res.json({ message: "Order updated", data: order });
  } catch (err) {
    next(err);
  }
};

exports.deleteOrder = async (req, res, next) => {
  try {
    await orderService.deleteOrder(req.params.id);
    res.json({ message: "Order deleted" });
  } catch (err) {
    next(err);
  }
};

exports.updateOrderItems = async (req, res, next) => {
  try {
    const updatedOrder = await orderService.updateOrderItems(
      req.params.id,
      req.body.items
    );
    res.json({ message: "Order items updated", data: updatedOrder });
  } catch (err) {
    next(err);
  }
};
