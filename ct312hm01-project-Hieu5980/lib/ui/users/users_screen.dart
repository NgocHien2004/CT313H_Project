import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../Themes/app_colors.dart';
import '../../services/api/user_api.dart';
import '../../models/user.dart';
import '../../utils/responsive.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _api = UserAPI();
  List<User> _users = [];
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
      final res = await _api.getAll(params: {'limit': 100});
      final List raw = (res.data['data'] ?? res.data) as List;
      setState(() {
        _users = raw
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .where((u) => !u.isDeleted)
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Không tải được danh sách';
        _isLoading = false;
      });
    }
  }

  Future<void> _showForm({User? user}) async {
    final r = Responsive(context);
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final passCtrl = TextEditingController();
    String selRole = user?.role ?? 'user';
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
                  user == null ? 'Thêm người dùng' : 'Sửa người dùng',
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
                        label: 'Họ tên',
                        placeholder: 'Nhập họ tên',
                        controller: nameCtrl,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Vui lòng nhập họ tên'
                            : null,
                      ),
                      SizedBox(height: r.isTablet ? 16 : 12),
                      _field(
                        r: r,
                        label: 'Email',
                        placeholder: 'Nhập email',
                        controller: emailCtrl,
                        keyboard: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Vui lòng nhập email';
                          if (!v.contains('@')) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      SizedBox(height: r.isTablet ? 16 : 12),
                      _field(
                        r: r,
                        label: user == null
                            ? 'Mật khẩu'
                            : 'Mật khẩu mới (để trống để giữ cũ)',
                        placeholder: 'Ít nhất 6 ký tự',
                        controller: passCtrl,
                        obscure: true,
                        validator: user == null
                            ? (v) => (v == null || v.length < 6)
                                  ? 'Mật khẩu tối thiểu 6 ký tự'
                                  : null
                            : null,
                      ),
                      SizedBox(height: r.isTablet ? 16 : 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vai trò',
                            style: TextStyle(
                              fontSize: r.sp(14),
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: selRole,
                            style: TextStyle(
                              fontSize: r.sp(14),
                              color: AppColors.gray900,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
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
                                  width: 2,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'user',
                                child: Text('Nhân viên'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Quản trị viên'),
                              ),
                            ],
                            onChanged: (v) => setS(() => selRole = v ?? 'user'),
                          ),
                        ],
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
                                final data = <String, dynamic>{
                                  'name': nameCtrl.text.trim(),
                                  'email': emailCtrl.text.trim(),
                                  'role': selRole,
                                };
                                if (user == null) {
                                  data['password'] = passCtrl.text;
                                } else if (passCtrl.text.isNotEmpty) {
                                  data['password'] = passCtrl.text;
                                }
                                if (user == null) {
                                  await _api.create(data);
                                } else {
                                  await _api.update(_id(user.id), data);
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
                              user == null ? 'Thêm' : 'Lưu',
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

  Future<void> _delete(User user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa người dùng "${user.name}"?\nHành động này không thể hoàn tác.',
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
      await _api.delete(_id(user.id));
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
    bool obscure = false,
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
          obscureText: obscure,
          keyboardType: keyboard,
          maxLines: obscure ? 1 : maxLines,
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

  Widget _roleBadge(Responsive r, String role) {
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin
            ? AppColors.primary600.withOpacity(0.1)
            : AppColors.green50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdmin
              ? AppColors.primary600.withOpacity(0.3)
              : AppColors.green700.withOpacity(0.3),
        ),
      ),
      child: Text(
        isAdmin ? 'Quản trị viên' : 'Nhân viên',
        style: TextStyle(
          fontSize: r.sp(11),
          fontWeight: FontWeight.w600,
          color: isAdmin ? AppColors.primary600 : AppColors.green700,
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
        title: Text(
          'Người dùng (${_users.length})',
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
        child: const Icon(Icons.person_add),
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
    if (_users.isEmpty) {
      return Center(
        child: Text(
          'Chưa có người dùng nào',
          style: TextStyle(fontSize: r.sp(16), color: AppColors.gray600),
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
        itemCount: _users.length,
        separatorBuilder: (_, __) => SizedBox(height: r.itemSpacing),
        itemBuilder: (_, i) {
          final u = _users[i];
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
              leading: CircleAvatar(
                radius: r.isTablet ? 22 : 20,
                backgroundColor: AppColors.primary600.withOpacity(0.1),
                child: Text(
                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.primary600,
                    fontWeight: FontWeight.w700,
                    fontSize: r.sp(14),
                  ),
                ),
              ),
              title: Text(
                u.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: r.sp(14),
                  color: AppColors.gray900,
                ),
              ),
              subtitle: Text(
                u.email,
                style: TextStyle(fontSize: r.sp(13), color: AppColors.gray600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _roleBadge(r, u.role),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary600,
                      size: r.iconSize + 2,
                    ),
                    onPressed: () => _showForm(user: u),
                    tooltip: 'Sửa',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: r.iconSize + 2,
                    ),
                    onPressed: () => _delete(u),
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
