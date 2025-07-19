const { z: z3 } = require("zod");

exports.createOrderSchema = z3.object({
  user_id: z3.number().int(),
  table_number: z3.number().int(),
  items: z3.array(
    z3.object({
      dish_id: z3.number().int(),
      quantity: z3.number().int().min(1),
    })
  ),
});

exports.updateOrderSchema = z3.object({
  table_number: z3.number().int().min(1).optional(),
  note: z3.string().optional(),
});
