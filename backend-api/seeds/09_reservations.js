const { faker } = require("@faker-js/faker/locale/vi");

function createReservation() {
  return {
    customer_name: faker.person.fullName(),
    phone_number: faker.phone.number("09########"),
    number_of_guests: faker.number.int({ min: 2, max: 10 }),
    reservation_time: faker.date.soon(),
    status: "booked",
    created_at: new Date(),
  };
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = async function (knex) {
  await knex("reservations").del();
  const reservations = Array.from({ length: 10 }, createReservation);
  await knex("reservations").insert(reservations);
};
