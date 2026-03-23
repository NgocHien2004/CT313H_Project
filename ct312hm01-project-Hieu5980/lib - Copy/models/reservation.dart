class Reservation {
  final String? id;
  final String customerName;
  final String phoneNumber;
  final int numberOfGuests;
  final DateTime reservationTime;
  final String status;
  final DateTime? createdAt;

  Reservation({
    this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.numberOfGuests,
    required this.reservationTime,
    this.status = 'booked',
    this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> j) => Reservation(
    id: j['id']?.toString(),
    customerName: j['customer_name'] ?? '',
    phoneNumber: j['phone_number'] ?? '',
    numberOfGuests: int.tryParse(j['number_of_guests'].toString()) ?? 0,
    reservationTime:
        DateTime.tryParse(j['reservation_time'].toString()) ?? DateTime.now(),
    status: j['status'] ?? 'booked',
    createdAt: j['created_at'] != null
        ? DateTime.tryParse(j['created_at'].toString())
        : null,
  );
}
