import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../Themes/app_colors.dart';
import '../../services/api/user_api.dart';
import '../../models/user.dart';

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
        builder: (ctx, setS) => AlertDialog(
          title: Text(user == null ? 'Thêm người dùng' : 'Sửa người dùng'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (formErr != null) _errBox(formErr!),
                  _field(
                    label: 'Họ tên',
                    placeholder: 'Nhập họ tên',
                    controller: nameCtrl,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Vui lòng nhập họ tên'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: 'Email',
                    placeholder: 'Nhập email',
                    controller: emailCtrl,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                      if (!v.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _field(
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
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vai trò',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selRole,
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
                  : Text(user == null ? 'Thêm' : 'Lưu'),
            ),
          ],
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
          'Bạn có chắc muốn xóa người dùng "${user.name}"?\n'
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
          style: const TextStyle(
            fontSize: 14,
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

  Widget _roleBadge(String role) {
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isAdmin ? AppColors.primary600 : AppColors.green700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Text('Người dùng (${_users.length})'),
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
            ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có người dùng nào',
          style: TextStyle(fontSize: 16, color: AppColors.gray600),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final u = _users[i];
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
              leading: CircleAvatar(
                backgroundColor: AppColors.primary600.withOpacity(0.1),
                child: Text(
                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primary600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(
                u.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              subtitle: Text(
                u.email,
                style: const TextStyle(fontSize: 13, color: AppColors.gray600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _roleBadge(u.role),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary600,
                      size: 20,
                    ),
                    onPressed: () => _showForm(user: u),
                    tooltip: 'Sửa',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
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
