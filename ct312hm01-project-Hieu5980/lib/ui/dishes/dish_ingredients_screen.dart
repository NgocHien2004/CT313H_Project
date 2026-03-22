import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../Themes/app_colors.dart';
import '../../services/api/dish_ingredients_api.dart';
import '../../services/api/inventory_api.dart';
import '../../models/dish_ingredient.dart';
import '../../models/inventory.dart';

class DishIngredientsScreen extends StatefulWidget {
  final int dishId;
  final String dishName;

  const DishIngredientsScreen({
    super.key,
    required this.dishId,
    required this.dishName,
  });

  @override
  State<DishIngredientsScreen> createState() => _DishIngredientsScreenState();
}

class _DishIngredientsScreenState extends State<DishIngredientsScreen> {
  final _ingApi = DishIngredientsAPI();
  final _invApi = InventoryAPI();

  List<DishIngredient> _ingredients = [];
  List<Inventory> _inventory = [];
  bool _isLoading = true;
  String? _error;

  int _id(String? id) => int.tryParse(id ?? '') ?? 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _ingApi.getByDishId(widget.dishId),
        _invApi.getAll(params: {'limit': 200}),
      ]);
      final List rawIng =
          (results[0].data is List
                  ? results[0].data
                  : (results[0].data['data'] ?? results[0].data ?? []))
              as List;
      final List rawInv = (results[1].data['data'] ?? results[1].data) as List;
      setState(() {
        _ingredients = rawIng
            .map((e) => DishIngredient.fromJson(e as Map<String, dynamic>))
            .toList();
        _inventory = rawInv
            .map((e) => Inventory.fromJson(e as Map<String, dynamic>))
            .where((i) => !i.isDeleted)
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Không tải được công thức';
        _isLoading = false;
      });
    }
  }

  String _invName(int inventoryId) {
    final inv = _inventory.where((i) => _id(i.id) == inventoryId).firstOrNull;
    return inv?.name ?? '#$inventoryId';
  }

  String _invUnit(int inventoryId) {
    final inv = _inventory.where((i) => _id(i.id) == inventoryId).firstOrNull;
    return inv?.unit ?? '';
  }

  String _stockStatus(int inventoryId, double required) {
    final inv = _inventory.where((i) => _id(i.id) == inventoryId).firstOrNull;
    if (inv == null) return 'Không rõ';
    if (inv.quantity <= 0) return 'Hết hàng';
    if (inv.quantity < required) return 'Thiếu (${inv.quantity})';
    return 'Đủ (${inv.quantity})';
  }

  Color _stockColor(int inventoryId, double required) {
    final inv = _inventory.where((i) => _id(i.id) == inventoryId).firstOrNull;
    if (inv == null || inv.quantity <= 0) return Colors.red;
    if (inv.quantity < required) return const Color(0xFFD97706);
    return AppColors.green700;
  }

  Future<void> _showForm({DishIngredient? ing}) async {
    int? selectedInvId = ing?.inventoryId;
    final qtyCtrl = TextEditingController(
      text: ing?.quantityRequired.toStringAsFixed(0) ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    String? formErr;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(ing == null ? 'Thêm nguyên liệu' : 'Sửa nguyên liệu'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (formErr != null) _errBox(formErr!),
                // Chọn nguyên liệu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nguyên liệu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: selectedInvId,
                      isExpanded: true,
                      decoration: _inputDeco('Chọn nguyên liệu'),
                      items: _inventory
                          .map(
                            (inv) => DropdownMenuItem(
                              value: _id(inv.id),
                              child: Text(
                                '${inv.name} (${inv.unit ?? ''}) – tồn: ${inv.quantity}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: ing == null
                          ? (v) => setS(() => selectedInvId = v)
                          : null,
                      validator: (v) =>
                          v == null ? 'Vui lòng chọn nguyên liệu' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Số lượng
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số lượng cần',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDeco('Nhập số lượng'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Bắt buộc';
                        if (double.tryParse(v) == null) return 'Không hợp lệ';
                        if ((double.tryParse(v) ?? 0) <= 0)
                          return 'Phải lớn hơn 0';
                        return null;
                      },
                    ),
                  ],
                ),
              ],
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
                          'dish_id': widget.dishId,
                          'inventory_id': selectedInvId,
                          'quantity_required': double.parse(
                            qtyCtrl.text.trim(),
                          ),
                        };
                        if (ing == null) {
                          await _ingApi.create(data);
                        } else {
                          await _ingApi.update(_id(ing.id), {
                            'quantity_required': double.parse(
                              qtyCtrl.text.trim(),
                            ),
                          });
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadAll();
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
                  : Text(ing == null ? 'Thêm' : 'Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(DishIngredient ing) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Xóa nguyên liệu "${_invName(ing.inventoryId)}" khỏi công thức?\n'
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
      await _ingApi.delete(_id(ing.id));
      _loadAll();
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

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.gray300),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Công thức nguyên liệu', style: TextStyle(fontSize: 16)),
            Text(
              widget.dishName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
            ElevatedButton(onPressed: _loadAll, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (_ingredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.science_outlined, size: 64, color: AppColors.gray300),
            SizedBox(height: 12),
            Text(
              'Chưa có công thức nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nhấn + để thêm nguyên liệu',
              style: TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
          ],
        ),
      );
    }

    // Summary counts
    int sufficient = 0, insufficient = 0, outOfStock = 0;
    for (final ing in _ingredients) {
      final inv = _inventory
          .where((i) => _id(i.id) == ing.inventoryId)
          .firstOrNull;
      final qty = inv?.quantity ?? 0;
      if (qty <= 0)
        outOfStock++;
      else if (qty < ing.quantityRequired)
        insufficient++;
      else
        sufficient++;
    }

    return Column(
      children: [
        // Summary bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryChip(
                'Đủ: $sufficient',
                AppColors.green700,
                AppColors.green50,
              ),
              _summaryChip(
                'Thiếu: $insufficient',
                const Color(0xFFD97706),
                const Color(0xFFFEF3C7),
              ),
              _summaryChip(
                'Hết: $outOfStock',
                AppColors.red700,
                AppColors.red50,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAll,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _ingredients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final ing = _ingredients[i];
                final color = _stockColor(
                  ing.inventoryId,
                  ing.quantityRequired,
                );
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray300),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.science, color: color, size: 20),
                    ),
                    title: Text(
                      _invName(ing.inventoryId),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cần: ${ing.quantityRequired.toStringAsFixed(ing.quantityRequired % 1 == 0 ? 0 : 1)} '
                          '${_invUnit(ing.inventoryId)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.gray600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _stockStatus(ing.inventoryId, ing.quantityRequired),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary600,
                            size: 20,
                          ),
                          onPressed: () => _showForm(ing: ing),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _delete(ing),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryChip(String label, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: fg.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
    ),
  );
}
