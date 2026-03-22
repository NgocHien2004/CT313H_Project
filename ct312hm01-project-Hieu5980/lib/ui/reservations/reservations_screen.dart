import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../Themes/app_colors.dart';
import '../../services/api/reservations_api.dart';
import '../../models/reservation.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final _api = ReservationsAPI();

  List<Reservation> _items = [];
  bool _isLoading = true;
  String? _error;

  String _filterStatus = '';
  final _nameCtrl = TextEditingController();
  String _filterDate = '';

  int _id(String? id) => int.tryParse(id ?? '') ?? 0;

  DateTime? _lastType;
  void _onNameChanged(String _) {
    _lastType = DateTime.now();
    final snap = _lastType;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_lastType == snap) _load();
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final params = <String, dynamic>{
        'limit': 100,
        if (_filterStatus.isNotEmpty) 'status': _filterStatus,
        if (_nameCtrl.text.trim().isNotEmpty)
          'customer_name': _nameCtrl.text.trim(),
        if (_filterDate.isNotEmpty) 'date': _filterDate,
      };
      final res = await _api.getAll(params: params);
      final List raw = (res.data['data'] ?? res.data) as List;
      setState(() {
        _items = raw
            .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Không tải được đặt bàn';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(Reservation r, String status) async {
    try {
      await _api.update(_id(r.id), {'status': status});
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showForm({Reservation? r}) async {
    final nameCtrl = TextEditingController(text: r?.customerName ?? '');
    final phoneCtrl = TextEditingController(text: r?.phoneNumber ?? '');
    final guestCtrl = TextEditingController(
      text: r?.numberOfGuests.toString() ?? '2',
    );
    DateTime selectedDt =
        r?.reservationTime ?? DateTime.now().add(const Duration(hours: 1));
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    String? formErr;

    String _fmtDt(DateTime dt) =>
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(r == null ? 'Đặt bàn mới' : 'Sửa đặt bàn'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (formErr != null) _errBox(formErr!),
                  _field(
                    label: 'Tên khách hàng',
                    placeholder: 'Nhập tên khách hàng',
                    controller: nameCtrl,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: 'Số điện thoại',
                    placeholder: 'Nhập số điện thoại',
                    controller: phoneCtrl,
                    keyboard: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Vui lòng nhập SĐT';
                      if (v.length < 8) return 'Tối thiểu 8 chữ số';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: 'Số lượng khách',
                    placeholder: 'Nhập số lượng khách',
                    controller: guestCtrl,
                    keyboard: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Vui lòng nhập';
                      if ((int.tryParse(v) ?? 0) < 1)
                        return 'Tối thiểu 1 khách';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thời gian đặt bàn',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDt,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date == null) return;
                          final time = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.fromDateTime(selectedDt),
                          );
                          if (time != null) {
                            setS(
                              () => selectedDt = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.gray300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppColors.gray600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _fmtDt(selectedDt),
                                style: const TextStyle(
                                  color: AppColors.gray900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setS(() {
                        saving = true;
                        formErr = null;
                      });
                      try {
                        final data = {
                          'customer_name': nameCtrl.text.trim(),
                          'phone_number': phoneCtrl.text.trim(),
                          'number_of_guests': int.parse(guestCtrl.text.trim()),
                          'reservation_time': selectedDt.toIso8601String(),
                        };
                        if (r == null) {
                          await _api.create(data);
                        } else {
                          await _api.update(_id(r.id), data);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        _load();
                      } on DioException catch (e) {
                        final err = e.response?.data;
                        setS(
                          () => formErr =
                              (err is Map ? err['error'] : null)?.toString() ??
                              'Lỗi lưu dữ liệu',
                        );
                      } finally {
                        setS(() => saving = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: Colors.white,
              ),
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(r == null ? 'Đặt bàn' : 'Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(Reservation r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa đặt bàn của "${r.customerName}"?\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.delete(_id(r.id));
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _errBox(String msg) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.red50,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Text(msg, style: TextStyle(fontSize: 14, color: AppColors.red700)),
  );

  Widget _field({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          validator: validator,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: AppColors.gray300),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.primary500,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'booked':
        bg = AppColors.green50;
        fg = AppColors.green700;
        label = 'Đang chờ';
        break;
      case 'canceled':
        bg = AppColors.red50;
        fg = AppColors.red700;
        label = 'Đã hủy';
        break;
      case 'done':
        bg = AppColors.primary600.withOpacity(0.1);
        fg = AppColors.primary600;
        label = 'Hoàn thành';
        break;
      default:
        bg = AppColors.gray100;
        fg = AppColors.gray600;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Text('Đặt bàn (${_items.length})'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final e in {
                        '': 'Tất cả',
                        'booked': 'Đã đặt',
                        'done': 'Hoàn thành',
                        'canceled': 'Đã hủy',
                      }.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              e.value,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: _filterStatus == e.key,
                            onSelected: (_) {
                              setState(() => _filterStatus = e.key);
                              _load();
                            },
                            selectedColor: AppColors.primary600,
                            labelStyle: TextStyle(
                              color: _filterStatus == e.key
                                  ? Colors.white
                                  : AppColors.gray700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: TextField(
                          controller: _nameCtrl,
                          onChanged: _onNameChanged,
                          decoration: InputDecoration(
                            hintText: 'Tên khách hàng...',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.gray300,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: AppColors.gray600,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: AppColors.gray300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: AppColors.gray300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: AppColors.primary500,
                                width: 1.5,
                              ),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(
                              () => _filterDate =
                                  '${picked.year}-'
                                  '${picked.month.toString().padLeft(2, '0')}-'
                                  '${picked.day.toString().padLeft(2, '0')}',
                            );
                            _load();
                          }
                        },
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.gray300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: AppColors.gray600,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _filterDate.isEmpty ? 'Ngày' : _filterDate,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _filterDate.isEmpty
                                        ? AppColors.gray300
                                        : AppColors.gray900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_filterDate.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _filterDate = '');
                                    _load();
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppColors.gray600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(fontSize: 16, color: AppColors.gray600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.gray300,
            ),
            SizedBox(height: 12),
            Text(
              'Không có đặt bàn nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final r = _items[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                      _statusBadge(r.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: AppColors.gray600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        r.phoneNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.people,
                        size: 14,
                        color: AppColors.gray600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${r.numberOfGuests} khách',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.gray600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _fmtDate(r.reservationTime),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (r.status == 'booked') ...[
                        _actionBtn(
                          'Hoàn thành',
                          AppColors.green50,
                          AppColors.green700,
                          () => _updateStatus(r, 'done'),
                        ),
                        const SizedBox(width: 8),
                        _actionBtn(
                          'Hủy bàn',
                          AppColors.red50,
                          AppColors.red700,
                          () => _updateStatus(r, 'canceled'),
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary600,
                          size: 20,
                        ),
                        onPressed: () => _showForm(r: r),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: 'Sửa',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _actionBtn(String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: fg.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
