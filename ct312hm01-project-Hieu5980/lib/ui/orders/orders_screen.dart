import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../Themes/app_colors.dart';
import '../../services/api/orders_api.dart';
import '../../services/api/order_items_api.dart';
import '../../services/api/dishes_api.dart';
import '../../services/api/dish_ingredients_api.dart';
import '../../services/api/inventory_api.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/dish.dart';
import '../../models/dish_ingredient.dart';
import '../../models/inventory.dart';
import 'package:restaurant_app/ui/dishes/dishes_screen.dart'
    show calcDishAvailable;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _ordersApi = OrdersAPI();
  final _itemsApi = OrderItemsAPI();
  final _dishesApi = DishesAPI();
  final _ingApi = DishIngredientsAPI();
  final _invApi = InventoryAPI();
  final _storage = const FlutterSecureStorage();

  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  String _filterStatus = '';
  final _tableCtrl = TextEditingController();
  String _filterDate = '';

  int _id(String? id) => int.tryParse(id ?? '') ?? 0;

  String _fmtVnd(double amount) {
    final s = amount.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf}đ';
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tableCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final params = <String, dynamic>{
        'limit': 50,
        if (_filterStatus.isNotEmpty) 'status': _filterStatus,
        if (_tableCtrl.text.trim().isNotEmpty)
          'table_number': _tableCtrl.text.trim(),
        if (_filterDate.isNotEmpty) 'date': _filterDate,
      };
      final res = await _ordersApi.getAll(params: params);
      final List raw = (res.data['data'] ?? res.data) as List;
      setState(() {
        _orders = raw
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Không tải được đơn hàng';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(Order order, String status) async {
    try {
      await _ordersApi.update(_id(order.id), {'status': status});
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

  Future<void> _delete(Order order) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa đơn hàng #${order.id}?\n'
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
      await _ordersApi.delete(_id(order.id));
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

  Future<void> _showCreateOrder() async {
    List<Dish> allDishes = [];
    Map<int, List<DishIngredient>> ingMap = {};
    Map<int, Inventory> invMap = {};
    final Map<int, int> cart = {};
    final tableCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    bool loadingDishes = true;
    String? formErr;

    String _imgUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      if (url.startsWith('http')) return url;
      return 'http://10.0.2.2:3000$url';
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          if (loadingDishes) {
            Future.wait([
                  _dishesApi.getAll(params: {'limit': 200}),
                  _invApi.getAll(params: {'limit': 500}),
                ])
                .then((results) async {
                  final List rawD =
                      (results[0].data['data'] ?? results[0].data) as List;
                  final List rawI =
                      (results[1].data['data'] ?? results[1].data) as List;

                  final dishes = rawD
                      .map((e) => Dish.fromJson(e as Map<String, dynamic>))
                      .where((d) => !d.isDeleted)
                      .toList();

                  final iMap = <int, Inventory>{};
                  for (final e in rawI) {
                    final inv = Inventory.fromJson(e as Map<String, dynamic>);
                    if (!inv.isDeleted) iMap[_id(inv.id)] = inv;
                  }

                  final ingResults = await Future.wait(
                    dishes.map(
                      (d) => _ingApi
                          .getByDishId(_id(d.id))
                          .then((r) {
                            final List ri = r.data is List
                                ? r.data
                                : (r.data['data'] ?? r.data ?? []);
                            return MapEntry(
                              _id(d.id),
                              ri
                                  .map(
                                    (e) => DishIngredient.fromJson(
                                      e as Map<String, dynamic>,
                                    ),
                                  )
                                  .toList(),
                            );
                          })
                          .catchError(
                            (_) => MapEntry(_id(d.id), <DishIngredient>[]),
                          ),
                    ),
                  );
                  final gMap = Map<int, List<DishIngredient>>.fromEntries(
                    ingResults,
                  );

                  final available = dishes
                      .where((d) => calcDishAvailable(_id(d.id), gMap, iMap))
                      .toList();

                  setS(() {
                    allDishes = available;
                    ingMap = gMap;
                    invMap = iMap;
                    loadingDishes = false;
                  });
                })
                .catchError((_) => setS(() => loadingDishes = false));
          }

          final total = cart.entries.fold(0.0, (s, e) {
            final d = allDishes.where((d) => _id(d.id) == e.key).firstOrNull;
            return s + (d?.price ?? 0) * e.value;
          });

          return AlertDialog(
            title: const Text('Tạo đơn hàng mới'),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (formErr != null) _errBox(formErr!),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Số bàn',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: tableCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco('Nhập số bàn'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Bắt buộc';
                              if (int.tryParse(v) == null)
                                return 'Số không hợp lệ';
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (cart.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.gray300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Đã chọn:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.gray900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...cart.entries.map((entry) {
                                final d = allDishes
                                    .where((d) => _id(d.id) == entry.key)
                                    .firstOrNull;
                                final url = _imgUrl(d?.imageUrl);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: url.isNotEmpty
                                            ? Image.network(
                                                url,
                                                width: 36,
                                                height: 36,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _miniPh(),
                                              )
                                            : _miniPh(),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d?.name ?? '#${entry.key}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (d != null)
                                              Text(
                                                _fmtVnd(d.price * entry.value),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.primary600,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          size: 18,
                                        ),
                                        onPressed: () => setS(() {
                                          if (entry.value <= 1)
                                            cart.remove(entry.key);
                                          else
                                            cart[entry.key] = entry.value - 1;
                                        }),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                      ),
                                      Text(
                                        '${entry.value}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          size: 18,
                                        ),
                                        onPressed: () => setS(
                                          () =>
                                              cart[entry.key] = entry.value + 1,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const Divider(height: 12),
                              Text(
                                'Tổng: ${_fmtVnd(total)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          loadingDishes
                              ? 'Đang tải món ăn...'
                              : 'Chọn món (${allDishes.length} có sẵn):',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      loadingDishes
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : allDishes.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Không có món nào đủ nguyên liệu.',
                                style: TextStyle(color: AppColors.gray600),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : SizedBox(
                              height: 220,
                              child: ListView.builder(
                                itemCount: allDishes.length,
                                itemBuilder: (_, i) {
                                  final d = allDishes[i];
                                  final dishId = _id(d.id);
                                  final url = _imgUrl(d.imageUrl);
                                  final inCart = cart.containsKey(dishId);

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: url.isNotEmpty
                                          ? Image.network(
                                              url,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _dishPh(),
                                            )
                                          : _dishPh(),
                                    ),
                                    title: Text(
                                      d.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.gray900,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _fmtVnd(d.price),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary600,
                                      ),
                                    ),
                                    trailing: inCart
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.green50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppColors.green700
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              '✓ ${cart[dishId]}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.green700,
                                              ),
                                            ),
                                          )
                                        : IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: AppColors.green700,
                                              size: 24,
                                            ),
                                            onPressed: () => setS(
                                              () => cart[dishId] =
                                                  (cart[dishId] ?? 0) + 1,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                          ),
                                    onTap: () => setS(
                                      () => cart[dishId] =
                                          (cart[dishId] ?? 0) + 1,
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: (saving || cart.isEmpty)
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setS(() {
                          saving = true;
                          formErr = null;
                        });
                        try {
                          final userId = await _storage.read(key: 'user_id');
                          await _ordersApi.create({
                            'table_number': int.parse(tableCtrl.text.trim()),
                            if (userId != null) 'user_id': int.parse(userId),
                            'items': cart.entries
                                .map(
                                  (e) => {
                                    'dish_id': e.key,
                                    'quantity': e.value,
                                  },
                                )
                                .toList(),
                          });
                          if (ctx.mounted) Navigator.pop(ctx);
                          _load();
                        } on DioException catch (e) {
                          setS(
                            () => formErr =
                                (e.response?.data as Map?)?['error']
                                    ?.toString() ??
                                'Lỗi tạo đơn hàng',
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
                    : const Text('Tạo đơn'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _miniPh() => Container(
    width: 36,
    height: 36,
    color: AppColors.gray100,
    child: const Icon(Icons.restaurant, size: 18, color: AppColors.gray300),
  );

  Widget _dishPh() => Container(
    width: 48,
    height: 48,
    color: AppColors.gray100,
    child: const Icon(Icons.restaurant, size: 22, color: AppColors.gray300),
  );

  Future<void> _showDetail(Order order) async {
    List<OrderItem> items = [];
    List<Dish> allDishes = [];
    List<Dish> availDishes = [];
    Map<int, String> dishNames = {};
    Map<int, String> dishImages = {};
    bool loadingDetail = true;
    String? detailErr;

    String _imgUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      if (url.startsWith('http')) return url;
      return 'http://10.0.2.2:3000$url';
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          if (loadingDetail) {
            Future.wait([
                  _ordersApi.getById(_id(order.id)),
                  _dishesApi.getAll(params: {'limit': 200}),
                  _invApi.getAll(params: {'limit': 500}),
                ])
                .then((results) async {
                  final od = results[0].data['data'] ?? results[0].data;
                  final List rawItems = (od['items'] ?? []) as List;
                  final List rawDishes =
                      (results[1].data['data'] ?? results[1].data) as List;
                  final List rawInv =
                      (results[2].data['data'] ?? results[2].data) as List;

                  final dishes = rawDishes
                      .map((e) => Dish.fromJson(e as Map<String, dynamic>))
                      .where((d) => !d.isDeleted)
                      .toList();

                  final invMap = <int, Inventory>{};
                  for (final e in rawInv) {
                    final inv = Inventory.fromJson(e as Map<String, dynamic>);
                    if (!inv.isDeleted) invMap[_id(inv.id)] = inv;
                  }

                  final ingResults = await Future.wait(
                    dishes.map(
                      (d) => _ingApi
                          .getByDishId(_id(d.id))
                          .then((r) {
                            final List ri = r.data is List
                                ? r.data
                                : (r.data['data'] ?? r.data ?? []);
                            return MapEntry(
                              _id(d.id),
                              ri
                                  .map(
                                    (e) => DishIngredient.fromJson(
                                      e as Map<String, dynamic>,
                                    ),
                                  )
                                  .toList(),
                            );
                          })
                          .catchError(
                            (_) => MapEntry(_id(d.id), <DishIngredient>[]),
                          ),
                    ),
                  );
                  final ingMap = Map<int, List<DishIngredient>>.fromEntries(
                    ingResults,
                  );

                  final avail = dishes
                      .where(
                        (d) => calcDishAvailable(_id(d.id), ingMap, invMap),
                      )
                      .toList();

                  for (final d in dishes) {
                    dishNames[_id(d.id)] = d.name;
                    dishImages[_id(d.id)] = d.imageUrl ?? '';
                  }

                  setS(() {
                    allDishes = dishes;
                    availDishes = avail;
                    items = rawItems
                        .map(
                          (e) => OrderItem.fromJson(e as Map<String, dynamic>),
                        )
                        .toList();
                    loadingDetail = false;
                  });
                })
                .catchError(
                  (_) => setS(() {
                    detailErr = 'Không tải được chi tiết';
                    loadingDetail = false;
                  }),
                );
          }

          final total = items.fold(0.0, (s, it) => s + it.price * it.quantity);

          Future<void> reloadItems() async {
            final r = await _ordersApi.getById(_id(order.id));
            final od = r.data['data'] ?? r.data;
            final List ri = (od['items'] ?? []) as List;
            setS(() {
              items = ri
                  .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
                  .toList();
            });
            _load();
          }

          return AlertDialog(
            title: Text('Đơn #${order.id} – Bàn ${order.tableNumber}'),
            content: SizedBox(
              width: double.maxFinite,
              child: loadingDetail
                  ? const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : detailErr != null
                  ? Text(detailErr!, style: const TextStyle(color: Colors.red))
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              _statusBadge(order.status),
                              const Spacer(),
                              Text(
                                _fmtVnd(total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.primary600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 8),

                          if (items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Chưa có món nào',
                                style: TextStyle(color: AppColors.gray600),
                              ),
                            )
                          else
                            ...items.map((it) {
                              final imgUrl = _imgUrl(dishImages[it.dishId]);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: imgUrl.isNotEmpty
                                          ? Image.network(
                                              imgUrl,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _miniPh(),
                                            )
                                          : _miniPh(),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dishNames[it.dishId] ??
                                                'Món #${it.dishId}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.gray900,
                                            ),
                                          ),
                                          Text(
                                            _fmtVnd(it.price),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.gray600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (order.status == 'pending') ...[
                                      _qtyBtn(Icons.remove, () async {
                                        if (it.quantity <= 1) {
                                          await _itemsApi.delete(_id(it.id));
                                        } else {
                                          await _itemsApi.update(_id(it.id), {
                                            'quantity': it.quantity - 1,
                                          });
                                        }
                                        await reloadItems();
                                      }),
                                    ],
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Text(
                                        'x${it.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.gray900,
                                        ),
                                      ),
                                    ),
                                    if (order.status == 'pending') ...[
                                      _qtyBtn(Icons.add, () async {
                                        await _itemsApi.update(_id(it.id), {
                                          'quantity': it.quantity + 1,
                                        });
                                        await reloadItems();
                                      }),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () async {
                                          await _itemsApi.delete(_id(it.id));
                                          await reloadItems();
                                        },
                                        child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      _fmtVnd(it.price * it.quantity),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.gray900,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                          if (order.status == 'pending' &&
                              availDishes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Text(
                              'Thêm món (${availDishes.length} có sẵn):',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 180,
                              child: ListView.builder(
                                itemCount: availDishes.length,
                                itemBuilder: (_, i) {
                                  final d = availDishes[i];
                                  final dishId = _id(d.id);
                                  final url = _imgUrl(d.imageUrl);
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 2,
                                    ),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: url.isNotEmpty
                                          ? Image.network(
                                              url,
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _dishPh(),
                                            )
                                          : _dishPh(),
                                    ),
                                    title: Text(
                                      d.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.gray900,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _fmtVnd(d.price),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary600,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: AppColors.green700,
                                        size: 22,
                                      ),
                                      onPressed: () async {
                                        final existing = items
                                            .where((it) => it.dishId == dishId)
                                            .firstOrNull;
                                        if (existing != null) {
                                          await _itemsApi.update(
                                            _id(existing.id),
                                            {'quantity': existing.quantity + 1},
                                          );
                                        } else {
                                          await _itemsApi.create({
                                            'order_id': _id(order.id),
                                            'dish_id': dishId,
                                            'quantity': 1,
                                            'price': d.price,
                                          });
                                        }
                                        await reloadItems();
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Icon(icon, size: 18, color: AppColors.gray600),
  );

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'Đang chờ';
        break;
      case 'completed':
        bg = AppColors.green50;
        fg = AppColors.green700;
        label = 'Hoàn thành';
        break;
      case 'canceled':
        bg = AppColors.red50;
        fg = AppColors.red700;
        label = 'Đã hủy';
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Text('Đơn hàng (${_orders.length})'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOrder,
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
                        'pending': 'Đang chờ',
                        'completed': 'Hoàn thành',
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
                          controller: _tableCtrl,
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => _load(),
                          decoration: InputDecoration(
                            hintText: 'Số bàn...',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.gray300,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
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
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.gray300,
            ),
            SizedBox(height: 12),
            Text(
              'Không có đơn hàng nào',
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
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final o = _orders[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray300),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showDetail(o),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary600.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${o.tableNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.primary600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đơn #${o.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmtVnd(o.totalAmount),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (o.createdAt != null)
                            Text(
                              _fmtDate(o.createdAt!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.gray600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _statusBadge(o.status),
                        const SizedBox(height: 6),
                        if (o.status == 'pending')
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _updateStatus(o, 'completed'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.green50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.green700.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Hoàn thành',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.green700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _updateStatus(o, 'canceled'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.red50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.red700.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Hủy',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.red700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
