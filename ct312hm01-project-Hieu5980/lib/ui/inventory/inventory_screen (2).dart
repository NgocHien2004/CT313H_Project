import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../Themes/app_colors.dart';
import '../../services/api/inventory_api.dart';
import '../../services/api/inventory_logs_api.dart';
import '../../services/notification_service.dart';
import '../../models/inventory.dart';
import '../../models/inventory_log.dart';
import '../../utils/responsive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  final _invApi = InventoryAPI();
  final _logsApi = InventoryLogsAPI();
  final _storage = const FlutterSecureStorage();
  late TabController _tabCtrl;

  List<Inventory> _items = [];
  List<InventoryLog> _logs = [];
  bool _loadingItems = true;
  bool _loadingLogs = false;

  int _id(String? id) => int.tryParse(id ?? '') ?? 0;

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging && _tabCtrl.index == 1 && _logs.isEmpty) {
        _loadLogs();
      }
    });
    _loadItems();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkLowStock() async {
    try {
      final role = await _storage.read(key: 'user_role');
      if (role != 'admin') return;
      await NotificationService().checkAndNotifyLowStock(
        inventoryList: _items,
        isAdmin: true,
      );
    } catch (_) {}
  }

  Future<void> _loadItems() async {
    setState(() => _loadingItems = true);
    try {
      final res = await _invApi.getAll(params: {'limit': 200});
      final List raw = (res.data['data'] ?? res.data) as List;
      setState(() {
        _items = raw
            .map((e) => Inventory.fromJson(e as Map<String, dynamic>))
            .where((i) => !i.isDeleted)
            .toList();
        _loadingItems = false;
      });
      await _checkLowStock();
    } catch (_) {
      setState(() => _loadingItems = false);
    }
  }

  Future<void> _loadLogs() async {
    setState(() => _loadingLogs = true);
    try {
      final res = await _logsApi.getAll(params: {'limit': 100});
      final List raw = (res.data['data'] ?? res.data) as List;
      setState(() {
        _logs = raw
            .map((e) => InventoryLog.fromJson(e as Map<String, dynamic>))
            .toList();
        _loadingLogs = false;
      });
    } catch (_) {
      setState(() => _loadingLogs = false);
    }
  }

  String _inventoryName(int inventoryId) {
    final inv = _items.where((i) => _id(i.id) == inventoryId).firstOrNull;
    return inv?.name ?? '#$inventoryId';
  }

  String _stockLabel(Inventory item) {
    if (item.quantity <= 0) return 'Hết hàng';
    if (item.quantity <= item.minQuantity) return 'Sắp hết';
    if (item.quantity <= item.minQuantity * 2) return 'Cảnh báo';
    return 'Đủ hàng';
  }

  Color _stockColor(Inventory item) {
    if (item.quantity <= 0) return Colors.red;
    if (item.quantity <= item.minQuantity) return Colors.red;
    if (item.quantity <= item.minQuantity * 2) return const Color(0xFFD97706);
    return AppColors.green700;
  }

  Future<void> _showItemForm({Inventory? item}) async {
    final r = Responsive(context);
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final qtyCtrl = TextEditingController(
      text: item?.quantity.toString() ?? '',
    );
    final unitCtrl = TextEditingController(text: item?.unit ?? '');
    final minCtrl = TextEditingController(
      text: item?.minQuantity.toString() ?? '5',
    );
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    String? formErr;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: r.isTablet ? r.screenWidth * 0.2 : 24,
            vertical: r.isTablet ? 40 : 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(r.isTablet ? 28 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item == null ? 'Thêm nguyên liệu' : 'Sửa nguyên liệu',
                  style: TextStyle(
                    fontSize: r.sp(18),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: r.isTablet ? 20 : 16),
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (formErr != null) _errBox(r, formErr!),
                      _field(
                        r: r,
                        label: 'Tên nguyên liệu',
                        placeholder: 'Nhập tên nguyên liệu',
                        controller: nameCtrl,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Vui lòng nhập tên'
                            : null,
                      ),
                      SizedBox(height: r.isTablet ? 16 : 12),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              r: r,
                              label: 'Số lượng',
                              placeholder: '0',
                              controller: qtyCtrl,
                              keyboard: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Bắt buộc';
                                if (int.tryParse(v) == null)
                                  return 'Không hợp lệ';
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: r.isTablet ? 16 : 12),
                          Expanded(
                            child: _field(
                              r: r,
                              label: 'Đơn vị',
                              placeholder: 'kg, lít, cái...',
                              controller: unitCtrl,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: r.isTablet ? 16 : 12),
                      _field(
                        r: r,
                        label: 'Tồn kho tối thiểu',
                        placeholder: '5',
                        controller: minCtrl,
                        keyboard: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: r.isTablet ? 24 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Hủy', style: TextStyle(fontSize: r.sp(14))),
                    ),
                    SizedBox(width: r.isTablet ? 12 : 8),
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
                                  'name': nameCtrl.text.trim(),
                                  'quantity': int.parse(qtyCtrl.text.trim()),
                                  'unit': unitCtrl.text.trim(),
                                  'min_quantity':
                                      int.tryParse(minCtrl.text) ?? 5,
                                };
                                if (item == null) {
                                  await _invApi.create(data);
                                } else {
                                  await _invApi.update(_id(item.id), data);
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                _loadItems();
                              } on DioException catch (e) {
                                setS(
                                  () => formErr =
                                      (e.response?.data as Map?)?['error']
                                          ?.toString() ??
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
                          : Text(
                              item == null ? 'Thêm' : 'Lưu',
                              style: TextStyle(fontSize: r.sp(14)),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showStockIn({Inventory? preSelected}) async {
    final r = Responsive(context);
    int? selectedId = preSelected != null ? _id(preSelected.id) : null;
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    String? formErr;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: r.isTablet ? r.screenWidth * 0.2 : 24,
            vertical: r.isTablet ? 40 : 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(r.isTablet ? 28 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preSelected != null
                      ? 'Nhập kho: ${preSelected.name}'
                      : 'Nhập kho',
                  style: TextStyle(
                    fontSize: r.sp(18),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: r.isTablet ? 20 : 16),
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (formErr != null) _errBox(r, formErr!),
                      if (preSelected == null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nguyên liệu',
                              style: TextStyle(
                                fontSize: r.sp(14),
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: selectedId,
                              isExpanded: true,
                              style: TextStyle(
                                fontSize: r.sp(14),
                                color: AppColors.gray900,
                              ),
                              decoration: _inputDeco(r, 'Chọn nguyên liệu'),
                              items: _items
                                  .map(
                                    (inv) => DropdownMenuItem(
                                      value: _id(inv.id),
                                      child: Text(
                                        '${inv.name} (${inv.quantity} ${inv.unit ?? ''})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setS(() => selectedId = v),
                              validator: (v) =>
                                  v == null ? 'Vui lòng chọn' : null,
                            ),
                            SizedBox(height: r.isTablet ? 16 : 12),
                          ],
                        )
                      else ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.gray300),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_2,
                                color: AppColors.gray600,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tồn kho hiện tại: ${preSelected.quantity} ${preSelected.unit ?? ''}',
                                style: TextStyle(
                                  fontSize: r.sp(13),
                                  color: AppColors.gray700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: r.isTablet ? 16 : 12),
                      ],
                      _field(
                        r: r,
                        label: 'Số lượng nhập',
                        placeholder: 'Nhập số lượng (> 0)',
                        controller: qtyCtrl,
                        keyboard: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Bắt buộc';
                          final n = int.tryParse(v);
                          if (n == null) return 'Số không hợp lệ';
                          if (n <= 0) return 'Phải lớn hơn 0';
                          return null;
                        },
                      ),
                      SizedBox(height: r.isTablet ? 16 : 12),
                      _field(
                        r: r,
                        label: 'Ghi chú',
                        placeholder: 'Nhập ghi chú...',
                        controller: noteCtrl,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: r.isTablet ? 24 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Hủy', style: TextStyle(fontSize: r.sp(14))),
                    ),
                    SizedBox(width: r.isTablet ? 12 : 8),
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
                                final qty = int.parse(qtyCtrl.text.trim());
                                await _logsApi.create({
                                  'inventory_id': selectedId,
                                  'quantity_added': qty,
                                  'note': noteCtrl.text.trim(),
                                });
                                final current = _items
                                    .where((i) => _id(i.id) == selectedId)
                                    .firstOrNull;
                                if (current != null) {
                                  await _invApi.update(selectedId!, {
                                    'quantity': current.quantity + qty,
                                  });
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                _loadItems();
                                if (_tabCtrl.index == 1) _loadLogs();
                              } on DioException catch (e) {
                                setS(
                                  () => formErr =
                                      (e.response?.data as Map?)?['error']
                                          ?.toString() ??
                                      'Lỗi nhập kho',
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
                          : Text(
                              'Nhập kho',
                              style: TextStyle(fontSize: r.sp(14)),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteItem(Inventory item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa "${item.name}"?\nHành động này không thể hoàn tác.',
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
      await _invApi.delete(_id(item.id));
      _loadItems();
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

  Widget _errBox(Responsive r, String msg) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.red50,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Text(
      msg,
      style: TextStyle(fontSize: r.sp(14), color: AppColors.red700),
    ),
  );

  InputDecoration _inputDeco(Responsive r, String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.gray300, fontSize: r.sp(14)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      borderSide: const BorderSide(color: AppColors.primary500, width: 2),
    ),
  );

  Widget _field({
    required Responsive r,
    required String label,
    required String placeholder,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: r.sp(14),
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: r.sp(14)),
          decoration: _inputDeco(r, placeholder).copyWith(
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

  Widget _stockBadge(Responsive r, Inventory item) {
    final color = _stockColor(item);
    final label = _stockLabel(item);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: r.sp(11),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Text('Kho hàng', style: TextStyle(fontSize: r.sp(16))),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary600,
          unselectedLabelColor: AppColors.gray600,
          indicatorColor: AppColors.primary600,
          labelStyle: TextStyle(fontSize: r.sp(13)),
          tabs: const [
            Tab(text: 'Nguyên liệu'),
            Tab(text: 'Lịch sử nhập/xuất'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tabCtrl.index == 0 ? _showItemForm() : _showStockIn(),
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _loadingItems
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? Center(
                  child: Text(
                    'Kho trống',
                    style: TextStyle(
                      fontSize: r.sp(15),
                      color: AppColors.gray600,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadItems,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      r.horizontalPadding,
                      16,
                      r.horizontalPadding,
                      80,
                    ),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: r.itemSpacing),
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      final isLow = item.quantity <= item.minQuantity;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.borderRadius),
                          border: Border.all(
                            color: isLow
                                ? Colors.red.shade200
                                : AppColors.gray300,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(r.isTablet ? 14 : 12),
                          child: Row(
                            children: [
                              Container(
                                width: r.isTablet ? 50 : 44,
                                height: r.isTablet ? 50 : 44,
                                decoration: BoxDecoration(
                                  color: _stockColor(item).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    r.borderRadius,
                                  ),
                                ),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: _stockColor(item),
                                  size: r.iconSize + 4,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: r.sp(14),
                                        color: AppColors.gray900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.quantity} ${item.unit ?? ''}  (min: ${item.minQuantity})',
                                      style: TextStyle(
                                        fontSize: r.sp(12),
                                        color: isLow
                                            ? Colors.red
                                            : AppColors.gray600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _stockBadge(r, item),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_box_outlined,
                                      color: AppColors.green700,
                                      size: r.iconSize + 4,
                                    ),
                                    tooltip: 'Nhập kho',
                                    onPressed: () =>
                                        _showStockIn(preSelected: item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.primary600,
                                      size: r.iconSize + 2,
                                    ),
                                    onPressed: () => _showItemForm(item: item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: r.iconSize + 2,
                                    ),
                                    onPressed: () => _deleteItem(item),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

          _loadingLogs
              ? const Center(child: CircularProgressIndicator())
              : _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 48,
                        color: AppColors.gray300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có lịch sử',
                        style: TextStyle(
                          fontSize: r.sp(14),
                          color: AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadLogs,
                        child: const Text('Tải lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLogs,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      r.horizontalPadding,
                      16,
                      r.horizontalPadding,
                      80,
                    ),
                    itemCount: _logs.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: r.itemSpacing),
                    itemBuilder: (_, i) {
                      final log = _logs[i];
                      final isIn = log.quantityAdded > 0;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.borderRadius),
                          border: Border.all(color: AppColors.gray300),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(r.isTablet ? 14 : 12),
                          leading: Container(
                            width: r.isTablet ? 48 : 44,
                            height: r.isTablet ? 48 : 44,
                            decoration: BoxDecoration(
                              color: isIn ? AppColors.green50 : AppColors.red50,
                              borderRadius: BorderRadius.circular(
                                r.borderRadius,
                              ),
                            ),
                            child: Icon(
                              isIn ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isIn
                                  ? AppColors.green700
                                  : AppColors.red700,
                              size: r.iconSize + 2,
                            ),
                          ),
                          title: Text(
                            _inventoryName(log.inventoryId),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: r.sp(14),
                              color: AppColors.gray900,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${isIn ? '+' : ''}${log.quantityAdded}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: r.sp(13),
                                  color: isIn
                                      ? AppColors.green700
                                      : AppColors.red700,
                                ),
                              ),
                              if (log.note != null && log.note!.isNotEmpty)
                                Text(
                                  log.note!,
                                  style: TextStyle(
                                    fontSize: r.sp(12),
                                    color: AppColors.gray600,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                            _fmtDate(log.createdAt),
                            style: TextStyle(
                              fontSize: r.sp(11),
                              color: AppColors.gray600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
