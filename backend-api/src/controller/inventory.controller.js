const inventoryService = require("../services/inventory.service");
const knex = require("../database/knex");

exports.createInventory = async (req, res) => {
  const { name, quantity, unit, min_quantity } = req.body;

  const trx = await knex.transaction();

  try {
    const [inventory] = await trx("inventory")
      .insert({
        name,
        quantity,
        unit,
        min_quantity,
        is_deleted: false,
        updated_at: knex.fn.now(),
      })
      .returning("*");

    await trx("inventory_logs").insert({
      inventory_id: inventory.id,
      quantity_added: inventory.quantity,
      note: "Initial stock added",
      created_at: knex.fn.now(),
    });

    await trx.commit();
    res
      .status(201)
      .json({ message: "Inventory item created", data: inventory });
  } catch (err) {
    await trx.rollback();
    console.error(err);
    res.status(500).json({ message: "Failed to create inventory" });
  }
};

exports.getAllInventory = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination || {
      page: 1,
      limit: 10,
      offset: 0,
    };

    const inventory = await knex("inventory")
      .select("*")
      .where({ is_deleted: false })
      .limit(limit)
      .offset(offset);

    res.json({ data: inventory, page, limit });
  } catch (err) {
    next(err);
  }
};

exports.updateInventory = async (req, res) => {
  const { id } = req.params;
  const { name, quantity, unit, min_quantity } = req.body;

  const trx = await knex.transaction();

  try {
    const old = await trx("inventory").where({ id, is_deleted: false }).first();

    if (!old) {
      await trx.rollback();
      return res.status(404).json({ message: "Inventory item not found" });
    }

    const updatedFields = {
      updated_at: knex.fn.now(),
    };

    if (name !== undefined) updatedFields.name = name;
    if (quantity !== undefined) updatedFields.quantity = quantity;
    if (unit !== undefined) updatedFields.unit = unit;
    if (min_quantity !== undefined) updatedFields.min_quantity = min_quantity;

    const [updated] = await trx("inventory")
      .where({ id })
      .update(updatedFields)
      .returning("*");

    const delta = quantity !== undefined ? quantity - old.quantity : 0;
    if (delta !== 0) {
      await trx("inventory_logs").insert({
        inventory_id: id,
        quantity_added: delta,
        note: "Manual quantity update",
        created_at: knex.fn.now(),
      });
    }

    await trx.commit();
    res.json({ message: "Inventory updated", data: updated });
  } catch (err) {
    await trx.rollback();
    console.error(err);
    res.status(500).json({ message: "Failed to update inventory" });
  }
};

exports.deleteInventory = async (req, res) => {
  const { id } = req.params;

  const trx = await knex.transaction();

  try {
    const inventory = await trx("inventory")
      .where({ id, is_deleted: false })
      .first();

    if (!inventory) {
      await trx.rollback();
      return res.status(404).json({ message: "Inventory item not found" });
    }

    // Ghi log xoá
    await trx("inventory_logs").insert({
      inventory_id: id,
      quantity_added: -inventory.quantity,
      note: "Inventory item soft-deleted",
      created_at: knex.fn.now(),
    });

    // Soft delete
    await trx("inventory").where({ id }).update({
      is_deleted: true,
      updated_at: knex.fn.now(),
    });

    await trx.commit();
    res.json({ message: "Inventory soft-deleted" });
  } catch (err) {
    await trx.rollback();
    console.error("Lỗi khi xóa inventory:", err);
    res.status(500).json({ message: "Failed to delete inventory" });
  }
};
