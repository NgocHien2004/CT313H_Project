const { z: z8 } = require("zod");

exports.createInventoryLogSchema = z8.object({
  inventory_id: z8.number().int(),
  quantity_added: z8.number().int(),
  note: z8.string().min(1),
});
