const { z: z5 } = require("zod");

exports.createReservationSchema = z5.object({
  customer_name: z5.string().min(1, { message: "Tên khách hàng là bắt buộc" }),
  phone_number: z5
    .string()
    .min(8, { message: "Số điện thoại phải có ít nhất 8 chữ số" })
    .regex(/^\d+$/, { message: "Số điện thoại chỉ được chứa chữ số" }),
  number_of_guests: z5
    .number()
    .int()
    .positive({ message: "Số lượng khách phải là số nguyên dương" }),
  reservation_time: z5.string().refine((val) => !isNaN(Date.parse(val)), {
    message: "Invalid date format",
  }),
});

exports.updateReservationSchema = z5.object({
  customer_name: z5.string().optional(),
  phone_number: z5
    .string()
    .min(8, { message: "Số điện thoại phải có ít nhất 8 chữ số" })
    .regex(/^\d+$/, { message: "Số điện thoại chỉ được chứa chữ số" })
    .optional(),
  number_of_guests: z5
    .number()
    .int()
    .min(1, { message: "Số khách tối thiểu là 1" })
    .optional(),
  reservation_time: z5
    .string()
    .refine((val) => !isNaN(Date.parse(val)), {
      message: "Invalid date format",
    })
    .optional(),
  note: z5.string().optional(),
  status: z5.string().optional(),
});
