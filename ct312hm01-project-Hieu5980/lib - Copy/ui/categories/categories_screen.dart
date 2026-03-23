import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../Themes/app_colors.dart';
import '../../services/api/categories_api.dart';
import '../../models/category.dart';
import '../../utils/responsive.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _api = CategoriesAPI();

  List<Category> _items = [];
  bool _isLoading = true;
  String? _error;

  int _id(String? id) => int.tryParse(id ?? '') ?? 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _api.getAll();
      final List raw = res.data is List
          ? res.data
          : (res.data['data'] ?? res.data ?? []);
      setState(() {
        _items = raw
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .where((c) => !c.isDeleted)
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Không tải được danh mục';
        _isLoading = false;
      });
    }
  }

  Future<void> _showForm({Category? cat}) async {
    final r = Responsive(context);
    final nameCtrl = TextEditingController(text: cat?.name ?? '');
    final descCtrl = TextEditingController(text: cat?.description ?? '');
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
          child: Padding(
            padding: EdgeInsets.all(r.isTablet ? 28 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat == null ? 'Thêm danh mục' : 'Sửa danh mục',
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
                        label: 'Tên danh mục',
                        placeholder: 'Nhập tên danh mục',
                        controller: nameCtrl,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Vui lòng nhập tên'
                            : null,
                      ),
                      SizedBox(height: r.isTablet ? 16 : 12),
                      _field(
                        r: r,
                        label: 'Mô tả',
                        placeholder: 'Nhập mô tả (tùy chọn)',
                        controller: descCtrl,
                        maxLines: 3,
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
                                  'description': descCtrl.text.trim(),
                                };
                                if (cat == null) {
                                  await _api.create(data);
                                } else {
                                  await _api.update(_id(cat.id), data);
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                _load();
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
                              cat == null ? 'Thêm' : 'Lưu',
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

  Future<void> _delete(Category cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa danh mục "${cat.name}"?\nHành động này không thể hoàn tác.',
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
      await _api.delete(_id(cat.id));
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

  Widget _field({
    required Responsive r,
    required String label,
    required String placeholder,
    required TextEditingController controller,
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
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: r.sp(14)),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: AppColors.gray300, fontSize: r.sp(14)),
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

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Text(
          'Danh mục (${_items.length})',
          style: TextStyle(fontSize: r.sp(16)),
        ),
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
      body: _buildBody(r),
    );
  }

  Widget _buildBody(Responsive r) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: TextStyle(fontSize: r.sp(16), color: AppColors.gray600),
            ),
            SizedBox(height: r.isTablet ? 20 : 16),
            ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.category_outlined,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có danh mục nào',
              style: TextStyle(
                fontSize: r.sp(16),
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.add),
              label: const Text('Thêm danh mục'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          r.horizontalPadding,
          16,
          r.horizontalPadding,
          80,
        ),
        itemCount: _items.length,
        separatorBuilder: (_, __) => SizedBox(height: r.itemSpacing),
        itemBuilder: (_, i) {
          final cat = _items[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(r.borderRadius),
              border: Border.all(color: AppColors.gray300),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: r.horizontalPadding,
                vertical: r.isTablet ? 10 : 8,
              ),
              leading: Container(
                width: r.isTablet ? 44 : 40,
                height: r.isTablet ? 44 : 40,
                decoration: BoxDecoration(
                  color: AppColors.primary600.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Icon(
                  Icons.category,
                  color: AppColors.primary600,
                  size: r.iconSize,
                ),
              ),
              title: Text(
                cat.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: r.sp(14),
                  color: AppColors.gray900,
                ),
              ),
              subtitle: (cat.description != null && cat.description!.isNotEmpty)
                  ? Text(
                      cat.description!,
                      style: TextStyle(
                        fontSize: r.sp(13),
                        color: AppColors.gray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary600,
                      size: r.iconSize + 2,
                    ),
                    onPressed: () => _showForm(cat: cat),
                    tooltip: 'Sửa',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: r.iconSize + 2,
                    ),
                    onPressed: () => _delete(cat),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
