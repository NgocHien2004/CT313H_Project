const { z } = require("zod");

exports.createCategorySchema = z.object({
  name: z.string().min(1, "Name is required"),
  description: z.string().optional(),
});

exports.updateCategorySchema = z.object({
  name: z.string().optional(),
  description: z.string().optional(),
});
