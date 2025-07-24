const { z: z2 } = require("zod");

exports.createDishSchema = z2.object({
  name: z2.string().min(1),
  description: z2.string().optional(),
  price: z2.coerce.number().positive(),
  category_id: z2.coerce.number().int(),
  image_url: z2.string().url().optional(),
});

exports.updateDishSchema = z2.object({
  name: z2.string().min(1).optional(),
  price: z2.coerce.number().positive().optional(),
  description: z2.string().optional(),
  category_id: z2.coerce.number().int().optional(),
  image_url: z2.string().url().optional(),
});
