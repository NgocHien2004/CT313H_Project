const { z: z5 } = require("zod");

exports.createReservationSchema = z5.object({
  customer_name: z5.string().min(1),
  phone_number: z5.string().min(8),
  number_of_guests: z5.number().int().positive(),
  reservation_time: z5.string().refine((val) => !isNaN(Date.parse(val)), {
    message: "Invalid date format",
  }),
});

exports.updateReservationSchema = z5.object({
  customer_name: z5.string().optional(),
  phone_number: z5.string().optional(),
  number_of_guests: z5.number().int().min(1).optional(),
  reservation_time: z5
    .string()
    .refine((val) => !isNaN(Date.parse(val)), {
      message: "Invalid date format",
    })
    .optional(),
  note: z5.string().optional(),
  status: z5.string().optional(),
});
