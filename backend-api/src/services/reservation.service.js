const knex4 = require("../database/knex");

exports.createReservation = async (data) => {
  const [resv] = await knex4("reservations").insert(data).returning("*");
  return resv;
};

exports.getAllReservations = async ({ limit, offset, filters = {} }) => {
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

  // Get total count
  const [totalRow] = await countQuery.count("* as count");
  const total = Number(totalRow.count);

  // Get data with pagination
  const data = await query.orderBy("created_at", "desc").limit(limit).offset(offset);

  return { data, total };
};

exports.updateReservation = async (id, data) => {
  const [resv] = await knex4("reservations").where("id", id).update(data).returning("*");
  return resv;
};

exports.deleteReservation = async (id) => {
  return await knex4("reservations").where("id", id).del();
};
