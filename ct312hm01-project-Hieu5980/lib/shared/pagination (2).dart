import 'package:flutter/material.dart';
import '../../Themes/app_colors.dart';

// Widget phan trang dung chung cho moi man hinh
// Su dung:
//   PaginationBar(
//     currentPage: _page,
//     totalPages: _totalPages,
//     onPageChanged: (p) => _loadPage(p),
//   )
class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int page) onPageChanged;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Hien toi da 5 so trang xung quanh trang hien tai
    final pages = <int>[];
    final start = (currentPage - 2).clamp(1, totalPages);
    final end = (currentPage + 2).clamp(1, totalPages);
    for (int i = start; i <= end; i++) pages.add(i);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ve trang dau
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
            color: AppColors.primary,
          ),
          // Lui 1 trang
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
            color: AppColors.primary,
          ),
          // Cac so trang
          ...pages.map(
            (p) => GestureDetector(
              onTap: p == currentPage ? null : () => onPageChanged(p),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: p == currentPage
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: p == currentPage
                        ? AppColors.primary
                        : AppColors.gray100,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$p',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: p == currentPage ? Colors.white : AppColors.gray600,
                  ),
                ),
              ),
            ),
          ),
          // Tien 1 trang
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            color: AppColors.primary,
          ),
          // Den trang cuoi
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(totalPages)
                : null,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
