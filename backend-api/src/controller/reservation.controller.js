const reservationService = require("../services/reservation.service");

exports.createReservation = async (req, res, next) => {
  try {
    const reservation = await reservationService.createReservation(req.body);
    res.status(201).json({ message: "Reservation created", data: reservation });
  } catch (err) {
    next(err);
  }
};

exports.getAllReservations = async (req, res, next) => {
  try {
    const { page, limit, offset } = req.pagination || {
      page: 1,
      limit: 10,
      offset: 0,
    };
    const reservations = await reservationService.getAllReservations({
      limit,
      offset,
    });
    res.json({ data: reservations, page, limit });
  } catch (err) {
    next(err);
  }
};

exports.updateReservation = async (req, res, next) => {
  try {
    const reservation = await reservationService.updateReservation(
      req.params.id,
      req.body
    );
    res.json({ message: "Reservation updated", data: reservation });
  } catch (err) {
    next(err);
  }
};

exports.deleteReservation = async (req, res, next) => {
  try {
    await reservationService.deleteReservation(req.params.id);
    res.json({ message: "Reservation deleted" });
  } catch (err) {
    next(err);
  }
};
