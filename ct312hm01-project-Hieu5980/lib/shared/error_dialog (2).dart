import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../Themes/app_colors.dart';

// Cac loai loi foreign key tu PostgreSQL -> thong bao than thien
const _fkMessages = {
  'orders_user_id_fkey':
      'Người dùng này đang có đơn hàng trong hệ thống.\nVui lòng xử lý hết đơn hàng trước khi xóa.',
  'order_items_order_id_fkey':
      'Đơn hàng này đang có món ăn bên trong.\nVui lòng xóa các món trong đơn trước.',
  'order_items_dish_id_fkey':
      'Món ăn này đang được sử dụng trong một số đơn hàng.\nKhông thể xóa món ăn nay.',
  'dish_ingredients_dish_id_fkey':
      'Món ăn này đang có công thức nguyên liệu liên kết.\nVui lòng xóa công thức trước.',
  'dish_ingredients_inventory_id_fkey':
      'Nguyên liệu này đang được sử dụng trong công thức của một số món ăn.\nVui lòng cập nhật công thức trước khi xóa.',
  'inventory_logs_inventory_id_fkey':
      'Nguyên liệu này đang có lịch sử nhập kho.\nKhông thể xóa nguyên liệu này.',
  'dishes_category_id_fkey':
      'Danh mục này đang có món ăn bên trong.\nVui lòng chuyển món ăn sang danh mục khác trước khi xóa.',
};

// Lay thong bao than thien tu loi DioException hoac Exception bat ky
String friendlyError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    final raw = (data is Map)
        ? (data['error'] ?? data['message'] ?? '').toString()
        : '';

    // Quet cac foreign key constraint de biet ly do that su
    for (final entry in _fkMessages.entries) {
      if (raw.contains(entry.key)) return entry.value;
    }

    // Loi constraint chung (violates foreign key)
    if (raw.contains('violates foreign key')) {
      return 'Không thể xóa vì dữ liệu này đang được sử dụng ở nơi khác trong hệ thống.';
    }

    // Loi unique (trung email, ten...)
    if (raw.contains('unique') || raw.contains('duplicate')) {
      return 'Dữ liệu này đã tồn tại trong hệ thống. Vui lòng kiểm tra lại.';
    }

    // Loi server khac ma backend tra ve message ro rang
    if (raw.isNotEmpty) return raw;

    // HTTP status fallback
    final status = error.response?.statusCode;
    if (status == 404)
      return 'Không tìm thấy dữ liệu. Có thể đã bị xóa trước đó.';
    if (status == 403) return 'Bạn không có quyền thực hiện thao tác này.';
    if (status == 401)
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    if (status == 500) return ' lỗi máy chủ. Vui lòng thử lại sau.';
  }

  // Exception thong thuong
  final msg = error.toString();
  if (msg.contains('SocketException') || msg.contains('Connection')) {
    return 'Không có kết nối mạng. Vui lòng kiểm tra lại.';
  }

  return 'Đã xảy ra lỗi. Vui lòng thử lại.';
}

// Hien dialog loi voi thong bao than thien
Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required Object error,
}) {
  final message = friendlyError(error);
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: Text(message, style: const TextStyle(height: 1.5)),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Đã hiểu'),
        ),
      ],
    ),
  );
}
