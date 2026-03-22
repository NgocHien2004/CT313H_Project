const knex4 = require("../database/knex");

exports.createReservation = async (data) => {
  const [resv] = await knex4("reservations").insert(data).returning("*");
  return resv;
};

exports.getAllReservations = async ({
  page,
  limit = 10,
  offset,
  filters = {},
}) => {
  // Build query với filters
  let query = knex4("reservations").select("*");
  let countQuery = knex4("reservations");

  // Apply filters
  if (filters.status) {
    query = query.where("status", filters.status);
    countQuery = countQuery.where("status", filters.status);
  }

  if (filters.customer_name) {
    const searchPattern = `%${filters.customer_name}%`;
    query = query.where("customer_name", "ilike", searchPattern);
    countQuery = countQuery.where("customer_name", "ilike", searchPattern);
  }

  if (filters.date) {
    // Filter by date (reservation_time)
    const startDate = new Date(filters.date);
    const endDate = new Date(filters.date);
    endDate.setDate(endDate.getDate() + 1); // Next day

    query = query.whereBetween("reservation_time", [startDate, endDate]);
    countQuery = countQuery.whereBetween("reservation_time", [startDate, endDate]);
  }

  if (offset !== undefined) {
    page = Math.floor(offset / limit) + 1;
  }

  page = page || 1;
  const realOffset = (page - 1) * limit;

  // Get total count
  const [{ count }] = await countQuery.count("id as count");
  const total = Number(count);

  // Get data with pagination
  const data = await query
    .orderBy("created_at", "desc")
    .limit(limit)
    .offset(realOffset);

  return {
    data,
    total,
    page,
    totalPages: Math.ceil(total / limit),
  };
};

exports.updateReservation = async (id, data) => {
  const [resv] = await knex4("reservations")
    .where("id", id)
    .update(data)
    .returning("*");
  return resv;
};

exports.deleteReservation = async (id) => {
  return await knex4("reservations").where("id", id).del();
};