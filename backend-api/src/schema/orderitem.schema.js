const { z } = require("zod");

exports.createOrderItemSchema = z.object({
  order_id: z.number().int(),
  dish_id: z.number().int(),
  quantity: z.number().int().min(1),
  price: z.number().positive(),
});

exports.updateOrderItemSchema = z.object({
  quantity: z.number().int().min(1).optional(),
  price: z.number().positive().optional(),
});
