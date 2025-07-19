const knex4 = require("../database/knex");

exports.createReservation = async (data) => {
  const [resv] = await knex4("reservations").insert(data).returning("*");
  return resv;
};

exports.getAllReservations = async ({ limit, offset }) => {
  return await knex4("reservations").select("*").limit(limit).offset(offset);
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
