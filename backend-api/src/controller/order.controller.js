const orderService = require("../services/order.service");

const knex = require("../database/knex");

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

    // Lấy filters từ query parameters
    const filters = {
      status: req.query.status,
      table_number: req.query.table_number,
      date: req.query.date,
    };

    let orders;
    if (req.user.role === "admin") {
      orders = await orderService.getAllOrders({ limit, offset, filters });
    } else {
      orders = await orderService.getOrdersByUser({
        userId: req.user.id,
        limit,
        offset,
        filters,
      });
    }
    res.json({ data: orders.data, total: orders.total, page, limit });
  } catch (err) {
    next(err);
  }
};

exports.updateOrder = async (req, res) => {
  const orderId = req.params.id;
  const { table_number, status } = req.body;

  const trx = await knex.transaction();

  try {
    // Lấy order hiện tại
    const order = await trx("orders").where({ id: orderId }).first();

    if (!order) {
      await trx.rollback();
      return res.status(404).json({ message: "Order not found" });
    }

    // Nếu trạng thái chuyển thành 'completed', tiến hành trừ nguyên liệu
    if (status && order.status !== "completed" && status === "completed") {
      const orderItems = await trx("order_items").where({ order_id: orderId });

      for (const item of orderItems) {
        const ingredients = await trx("dish_ingredients").where({
          dish_id: item.dish_id,
        });

        for (const ing of ingredients) {
          const totalUsed = ing.quantity_required * item.quantity;

          // Trừ trong inventory
          await trx("inventory").where({ id: ing.inventory_id }).decrement("quantity", totalUsed).update({ updated_at: knex.fn.now() });

          // Ghi log
          await trx("inventory_logs").insert({
            inventory_id: ing.inventory_id,
            quantity_added: -totalUsed,
            note: `Used for order #${orderId}`,
            created_at: knex.fn.now(),
          });
        }
      }
    }

    // Cập nhật đơn hàng
    await trx("orders")
      .where({ id: orderId })
      .update({
        ...(table_number !== undefined && { table_number }),
        ...(status && { status }),
      });

    await trx.commit();
    res.json({ message: "Order updated successfully" });
  } catch (err) {
    console.error(err);
    await trx.rollback();
    res.status(500).json({ message: "Internal server error" });
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

exports.getOrderById = async (req, res, next) => {
  try {
    const orderId = req.params.id;
    const order = await orderService.getOrderById(orderId);
    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }
    res.json({ data: order });
  } catch (err) {
    next(err);
  }
};
