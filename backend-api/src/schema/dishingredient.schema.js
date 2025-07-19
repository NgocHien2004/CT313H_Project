const { z } = require("zod");

exports.createDishIngredientSchema = z.object({
  dish_id: z.number().int(),
  inventory_id: z.number().int(),
  quantity_required: z.number().positive(),
});

exports.updateDishIngredientSchema = z.object({
  dish_id: z.number().int().optional(),
  inventory_id: z.number().int().optional(),
  quantity_required: z.number().positive().optional(),
});
