// backend-api/src/schema/dish.schema.js
const { z: z2 } = require("zod");

// Custom transform để xử lý string boolean từ FormData
const booleanTransform = z2.preprocess((val) => {
  if (typeof val === "string") {
    return val.toLowerCase() === "true";
  }
  return Boolean(val);
}, z2.boolean());

exports.createDishSchema = z2.object({
  name: z2.string().min(1),
  description: z2.string().optional(),
  price: z2.coerce.number().positive(),
  category_id: z2.coerce.number().int(),
  image_url: z2.string().url().optional(),
  is_available: booleanTransform.optional().default(true),
});

exports.updateDishSchema = z2.object({
  name: z2.string().min(1).optional(),
  price: z2.coerce.number().positive().optional(),
  description: z2.string().optional(),
  category_id: z2.coerce.number().int().optional(),
  image_url: z2.string().url().optional(),
  is_available: booleanTransform.optional(), // Hỗ trợ toggle với transform
});
