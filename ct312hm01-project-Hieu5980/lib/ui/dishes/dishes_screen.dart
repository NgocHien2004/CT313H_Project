import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../Themes/app_colors.dart';
import '../../services/api/dishes_api.dart';
import '../../services/api/categories_api.dart';
import '../../services/api/dish_ingredients_api.dart';
import '../../services/api/inventory_api.dart';
import '../../models/dish.dart';
import '../../models/category.dart';
import '../../models/dish_ingredient.dart';
import '../../models/inventory.dart';

bool calcDishAvailable(
  int dishId,
  Map<int, List<DishIngredient>> ingredientMap,
  Map<int, Inventory> inventoryMap,
) {
  final ings = ingredientMap[dishId];
  if (ings == null || ings.isEmpty) return true;
  for (final ing in ings) {
    final inv = inventoryMap[ing.inventoryId];
    if (inv == null || inv.quantity < ing.quantityRequired) return false;
  }
  return true;
}

class DishesScreen extends StatefulWidget {
  const DishesScreen({super.key});
  @override
  State<DishesScreen> createState() => _DishesScreenState();
}

class _DishesScreenState extends State<DishesScreen> {
  final _dishApi = DishesAPI();
  final _catApi = CategoriesAPI();
  final _ingApi = DishIngredientsAPI();
  final _invApi = InventoryAPI();
  final _storage = const FlutterSecureStorage();

  List<Dish> _allDishes = [];
  List<Category> _categories = [];
  Map<int, List<DishIngredient>> _ingMap = {};
  Map<int, Inventory> _invMap = {};

  bool _isLoading = true;
  bool _isAdmin = false;
  String? _error;

  int _page = 1;
  final int _limit = 12;

  String _searchText = '';
  final _searchCtrl = TextEditingController();
  String _filterCatId = '';
  String _filterAvailable = '';

  int _id(String? id) => int.tryParse(id ?? '') ?? 0;

  String _fmtVnd(double v) {
    final s = v.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return '${b}đ';
  }

  List<Dish> get _filtered {
    var list = _allDishes;
    final q = _searchText.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (d) =>
                d.name.toLowerCase().contains(q) ||
                (d.description ?? '').toLowerCase().contains(q),
          )
          .toList();
    }
    if (_filterCatId.isNotEmpty) {
      final catId = int.tryParse(_filterCatId) ?? 0;
      list = list.where((d) => d.categoryId == catId).toList();
    }
    if (_filterAvailable.isNotEmpty) {
      final want = _filterAvailable == 'true';
      list = list.where((d) => _isAvailable(d) == want).toList();
    }
    return list;
  }

  List<Dish> get _paginated {
    final f = _filtered;
    final start = (_page - 1) * _limit;
    if (start >= f.length) return [];
    return f.sublist(start, (start + _limit).clamp(0, f.length));
  }

  int get _totalFiltered => _filtered.length;
  int get _totalPages => (_totalFiltered / _limit).ceil().clamp(1, 999);

  void _onSearchChanged(String value) => setState(() {
    _searchText = value;
    _page = 1;
  });
  void _onCategoryChanged(String? value) => setState(() {
    _filterCatId = value ?? '';
    _page = 1;
  });
  void _onAvailableChanged(String? value) => setState(() {
    _filterAvailable = value ?? '';
    _page = 1;
  });

  @override
  void initState() {
    super.initState();
    _loadAdminStatus();
    _loadCategories();
    _load();
  }

  Future<void> _loadAdminStatus() async {
    final role = await _storage.read(key: 'user_role');
    if (mounted) setState(() => _isAdmin = role == 'admin');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final res = await _catApi.getAll();
      final List raw = res.data is List
          ? res.data
          : (res.data['data'] ?? res.data ?? []);
      setState(() {
        _categories = raw
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .where((c) => !c.isDeleted)
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _dishApi.getAll(params: {'limit': 1000, 'page': 1});
      final List raw = (res.data['data'] ?? res.data) as List;
      final dishes = raw
          .map((e) => Dish.fromJson(e as Map<String, dynamic>))
          .where((d) => !d.isDeleted)
          .toList();

      final invRes = await _invApi.getAll(params: {'limit': 500});
      final List rawInv = (invRes.data['data'] ?? invRes.data) as List;
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
                        (e) =>
                            DishIngredient.fromJson(e as Map<String, dynamic>),
                      )
                      .toList(),
                );
              })
              .catchError((_) => MapEntry(_id(d.id), <DishIngredient>[])),
        ),
      );

      setState(() {
        _allDishes = dishes;
        _ingMap = Map.fromEntries(ingResults);
        _invMap = invMap;
        _page = 1;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Không tải được món ăn';
        _isLoading = false;
      });
    }
  }

  bool _isAvailable(Dish dish) =>
      calcDishAvailable(_id(dish.id), _ingMap, _invMap);

  String _catName(int catId) =>
      _categories.where((c) => _id(c.id) == catId).firstOrNull?.name ??
      'Chưa phân loại';

  String _imgUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return 'http://10.0.2.2:3000$imageUrl';
  }

  Future<void> _openForm({Dish? dish}) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DishFormScreen(dish: dish, categories: _categories),
      ),
    );
    if (ok == true) _load();
  }

  Future<void> _delete(Dish dish) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa món "${dish.name}"? Không thể hoàn tác.'),
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
      await _dishApi.delete(_id(dish.id));
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

  @override
  Widget build(BuildContext context) {
    final displayed = _paginated;
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Text('Món ăn ($_totalFiltered)'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _openForm(),
              backgroundColor: AppColors.primary600,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món ăn...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray300,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.gray600,
                      ),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                size: 16,
                                color: AppColors.gray600,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                _onSearchChanged('');
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                          width: 1.5,
                        ),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _filterCatId.isEmpty ? '' : _filterCatId,
                        isExpanded: true,
                        underline: Container(
                          height: 1,
                          color: AppColors.gray300,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray900,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Tất cả danh mục'),
                          ),
                          ..._categories.map(
                            (c) => DropdownMenuItem(
                              value: _id(c.id).toString(),
                              child: Text(
                                c.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: _onCategoryChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _filterAvailable,
                        isExpanded: true,
                        underline: Container(
                          height: 1,
                          color: AppColors.gray300,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray900,
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('Tất cả')),
                          DropdownMenuItem(
                            value: 'true',
                            child: Text('Có sẵn'),
                          ),
                          DropdownMenuItem(
                            value: 'false',
                            child: Text('Thiếu NL'),
                          ),
                        ],
                        onChanged: _onAvailableChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(child: _buildGrid(displayed)),

          if (!_isLoading && _totalFiltered > _limit)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _page > 1 ? () => setState(() => _page--) : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '$_page / $_totalPages',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray700,
                    ),
                  ),
                  IconButton(
                    onPressed: _page < _totalPages
                        ? () => setState(() => _page++)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Dish> dishes) {
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
    if (dishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 12),
            Text(
              _searchText.isNotEmpty ||
                      _filterCatId.isNotEmpty ||
                      _filterAvailable.isNotEmpty
                  ? 'Không tìm thấy món ăn phù hợp'
                  : 'Không có món ăn nào',
              style: const TextStyle(
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
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: _isAdmin ? 290.0 : 250.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: dishes.length,
        itemBuilder: (_, i) {
          final dish = dishes[i];
          final url = _imgUrl(dish.imageUrl);
          final available = _isAvailable(dish);
          final ings = _ingMap[_id(dish.id)] ?? [];
          final missing = ings.where((ing) {
            final inv = _invMap[ing.inventoryId];
            return inv == null || inv.quantity < ing.quantityRequired;
          }).toList();

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: available ? AppColors.gray300 : Colors.orange.shade300,
                width: available ? 1 : 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(7),
                      ),
                      child: ColorFiltered(
                        colorFilter: available
                            ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              )
                            : ColorFilter.mode(
                                Colors.grey.withOpacity(0.4),
                                BlendMode.darken,
                              ),
                        child: url.isNotEmpty
                            ? Image.network(
                                url,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _placeholder(),
                              )
                            : _placeholder(),
                      ),
                    ),
                    if (!available)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Thiếu NL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: available
                                ? AppColors.gray900
                                : AppColors.gray400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _catName(dish.categoryId),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.gray600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fmtVnd(dish.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (available)
                          _badge(
                            'Có sẵn',
                            AppColors.green50,
                            AppColors.green700,
                          )
                        else ...[
                          _badge(
                            'Thiếu NL',
                            const Color(0xFFFFF7ED),
                            Colors.orange.shade700,
                          ),
                          if (missing.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              missing
                                  .map((ing) {
                                    final inv = _invMap[ing.inventoryId];
                                    return '${inv?.name ?? '?'}: '
                                        '${inv?.quantity ?? 0}/'
                                        '${ing.quantityRequired.toStringAsFixed(0)}';
                                  })
                                  .join(', '),
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.gray600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],

                        const Spacer(),

                        if (_isAdmin)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _openForm(dish: dish),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary600.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Sửa',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _delete(dish),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.red50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Xóa',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.red700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
    ),
  );

  Widget _placeholder() => Image.asset(
    'assets/images/placeholder.jpg',
    height: 110,
    width: double.infinity,
    fit: BoxFit.cover,
  );
}

class DishFormScreen extends StatefulWidget {
  final Dish? dish;
  final List<Category> categories;
  const DishFormScreen({super.key, this.dish, required this.categories});
  @override
  State<DishFormScreen> createState() => _DishFormScreenState();
}

class _DishFormScreenState extends State<DishFormScreen>
    with SingleTickerProviderStateMixin {
  final _dishApi = DishesAPI();
  final _ingApi = DishIngredientsAPI();
  final _invApi = InventoryAPI();
  final _picker = ImagePicker();
  late TabController _tabCtrl;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? _selCatId;
  File? _imageFile;
  String _previewUrl = '';

  List<DishIngredient> _ingredients = [];
  List<Inventory> _inventory = [];
  bool _loadingIng = false;
  bool _ingLoaded = false;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.dish != null;
  int _id(String? id) => int.tryParse(id ?? '') ?? 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging && _tabCtrl.index == 1 && !_ingLoaded) {
        _loadIngredients();
      }
    });
    if (_isEdit) {
      final d = widget.dish!;
      _nameCtrl.text = d.name;
      _descCtrl.text = d.description ?? '';
      _priceCtrl.text = d.price.toStringAsFixed(0);
      _selCatId = d.categoryId;
      if (d.imageUrl != null && d.imageUrl!.isNotEmpty) {
        _previewUrl = d.imageUrl!.startsWith('http')
            ? d.imageUrl!
            : 'http://10.0.2.2:3000${d.imageUrl}';
      }
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (src == null) return;
    final picked = await _picker.pickImage(
      source: src,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _previewUrl = picked.path;
      });
    }
  }

  void _removeImage() => setState(() {
    _imageFile = null;
    _previewUrl = '';
  });

  Future<void> _loadIngredients() async {
    if (!_isEdit) return;
    setState(() => _loadingIng = true);
    try {
      final results = await Future.wait([
        _ingApi.getByDishId(_id(widget.dish!.id)),
        _invApi.getAll(params: {'limit': 500}),
      ]);
      final List rawIng = results[0].data is List
          ? results[0].data
          : (results[0].data['data'] ?? results[0].data ?? []);
      final List rawInv = (results[1].data['data'] ?? results[1].data) as List;
      setState(() {
        _ingredients = rawIng
            .map((e) => DishIngredient.fromJson(e as Map<String, dynamic>))
            .toList();
        _inventory = rawInv
            .map((e) => Inventory.fromJson(e as Map<String, dynamic>))
            .where((i) => !i.isDeleted)
            .toList();
        _loadingIng = false;
        _ingLoaded = true;
      });
    } catch (_) {
      setState(() => _loadingIng = false);
    }
  }

  String _invName(int id) =>
      _inventory.where((i) => _id(i.id) == id).firstOrNull?.name ?? '#$id';
  String _invUnit(int id) =>
      _inventory.where((i) => _id(i.id) == id).firstOrNull?.unit ?? '';

  Future<void> _showIngForm({DishIngredient? ing}) async {
    int? selInvId = ing?.inventoryId;
    final qtyCtrl = TextEditingController(
      text: ing == null
          ? ''
          : ing.quantityRequired.toStringAsFixed(
              ing.quantityRequired % 1 == 0 ? 0 : 1,
            ),
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
                _labeledField(
                  'Nguyên liệu',
                  child: DropdownButtonFormField<int>(
                    value: selInvId,
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
                        ? (v) => setS(() => selInvId = v)
                        : null,
                    validator: (v) => v == null ? 'Vui lòng chọn' : null,
                  ),
                ),
                const SizedBox(height: 12),
                _labeledField(
                  'Số lượng cần',
                  child: TextFormField(
                    controller: qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _inputDeco('Nhập số lượng'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Bắt buộc';
                      if ((double.tryParse(v) ?? 0) <= 0) return 'Phải > 0';
                      return null;
                    },
                  ),
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
                        final qty = double.parse(qtyCtrl.text.trim());
                        if (ing == null) {
                          await _ingApi.create({
                            'dish_id': _id(widget.dish!.id),
                            'inventory_id': selInvId,
                            'quantity_required': qty,
                          });
                        } else {
                          await _ingApi.update(_id(ing.id), {
                            'quantity_required': qty,
                          });
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadIngredients();
                      } on DioException catch (e) {
                        setS(
                          () => formErr =
                              (e.response?.data as Map?)?['error']
                                  ?.toString() ??
                              'Lỗi lưu',
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

  Future<void> _deleteIng(DishIngredient ing) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa nguyên liệu'),
        content: Text('Xóa "${_invName(ing.inventoryId)}" khỏi công thức?'),
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
      _loadIngredients();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa thất bại'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      if (_tabCtrl.index == 1) _tabCtrl.animateTo(0);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final fields = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'category_id': _selCatId,
        'is_available': 'true',
      };
      if (_imageFile != null) {
        fields['image'] = await MultipartFile.fromFile(
          _imageFile!.path,
          filename: _imageFile!.path.split('/').last,
        );
      }
      final fd = FormData.fromMap(fields);
      if (!_isEdit) {
        await _dishApi.create(fd);
      } else {
        await _dishApi.update(_id(widget.dish!.id), fd);
      }
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (e) {
      setState(
        () => _error =
            (e.response?.data as Map?)?['error']?.toString() ??
            'Lỗi lưu dữ liệu',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );

  Widget _labeledField(String label, {required Widget child}) => Column(
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
      child,
    ],
  );

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.gray700,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa món ăn' : 'Thêm món ăn mới'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _isEdit ? 'Lưu' : 'Tạo',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary600,
                      ),
                    ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary600,
          unselectedLabelColor: AppColors.gray600,
          indicatorColor: AppColors.primary600,
          tabs: const [
            Tab(text: 'Thông tin'),
            Tab(text: 'Nguyên liệu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) _errBox(_error!),
                  _sectionLabel('Hình ảnh món ăn'),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.gray300),
                      ),
                      child: _previewUrl.isNotEmpty
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: _imageFile != null
                                      ? Image.file(
                                          _imageFile!,
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          _previewUrl,
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _imgPh(),
                                        ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: _removeImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 48,
                                  color: AppColors.gray300,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Nhấn để chọn ảnh',
                                  style: TextStyle(
                                    color: AppColors.gray600,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'JPG, PNG, WEBP – tối đa 4MB',
                                  style: TextStyle(
                                    color: AppColors.gray300,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('Tên món ăn *'),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _inputDeco('Nhập tên món ăn'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('Mô tả'),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: _inputDeco('Nhập mô tả (tùy chọn)'),
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('Giá (VNĐ) *'),
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('Nhập giá bán'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Bắt buộc';
                      if (double.tryParse(v) == null) return 'Không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('Danh mục *'),
                  DropdownButtonFormField<int>(
                    value: _selCatId,
                    isExpanded: true,
                    decoration: _inputDeco('Chọn danh mục'),
                    items: widget.categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: _id(c.id),
                            child: Text(
                              c.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selCatId = v),
                    validator: (v) =>
                        v == null ? 'Vui lòng chọn danh mục' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEdit ? 'Lưu thay đổi' : 'Tạo món ăn',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          !_isEdit
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: AppColors.gray300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tạo món ăn trước,\nsau đó thêm nguyên liệu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _loadingIng
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${_ingredients.length} nguyên liệu',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _showIngForm(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Thêm'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _ingredients.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.science_outlined,
                                    size: 56,
                                    color: AppColors.gray300,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Chưa có nguyên liệu nào',
                                    style: TextStyle(color: AppColors.gray600),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _ingredients.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final ing = _ingredients[i];
                                final inv = _inventory
                                    .where(
                                      (it) => _id(it.id) == ing.inventoryId,
                                    )
                                    .firstOrNull;
                                final qty = inv?.quantity ?? 0;
                                final req = ing.quantityRequired;
                                Color sc;
                                String sl;
                                if (qty <= 0) {
                                  sc = AppColors.red700;
                                  sl = 'Hết hàng';
                                } else if (qty < req) {
                                  sc = const Color(0xFFD97706);
                                  sl = 'Thiếu ($qty)';
                                } else {
                                  sc = AppColors.green700;
                                  sl = 'Đủ ($qty)';
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.gray300,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: sc.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.science,
                                        color: sc,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      _invName(ing.inventoryId),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.gray900,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cần: ${req.toStringAsFixed(req % 1 == 0 ? 0 : 1)} '
                                          '${_invUnit(ing.inventoryId)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.gray600,
                                          ),
                                        ),
                                        Text(
                                          sl,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: sc,
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
                                          onPressed: () =>
                                              _showIngForm(ing: ing),
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
                                          onPressed: () => _deleteIng(ing),
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
                  ],
                ),
        ],
      ),
    );
  }

  Widget _imgPh() => Image.asset(
    'assets/images/placeholder.jpg',
    height: 180,
    width: double.infinity,
    fit: BoxFit.cover,
  );
}
