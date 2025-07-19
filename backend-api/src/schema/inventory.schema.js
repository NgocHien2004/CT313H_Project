const { z: z4 } = require("zod");

exports.createInventorySchema = z4.object({
  name: z4.string().min(1),
  quantity: z4.number().int().min(0),
  unit: z4.string().min(1),
});

exports.updateInventorySchema = z4.object({
  name: z4.string().optional(),
  quantity: z4.number().min(0).optional(),
  unit: z4.string().optional(),
});
