import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../Themes/app_colors.dart';
import '../providers/user_provider.dart';
import '../service_locator.dart';
import '../services/api/dishes_api.dart';
import '../services/api/orders_api.dart';
import '../services/api/reservations_api.dart';
import '../services/api/user_api.dart';
import '../routes/route_names.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dishesApi = sl<DishesAPI>();
  final _ordersApi = sl<OrdersAPI>();
  final _resApi = sl<ReservationsAPI>();
  final _userApi = sl<UserAPI>();

  int _totalDishes = 0;
  int _totalOrders = 0;
  int _totalResv = 0;
  int _totalUsers = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<UserProvider>().loadFromStorage();
      _loadStats();
    });
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    final isAdmin = context.read<UserProvider>().isAdmin;

    setState(() => _loadingStats = true);
    try {
      final results = await Future.wait([
        _dishesApi.getAll(params: {'limit': 1}),
        _ordersApi.getAll(params: {'limit': 1}),
        _resApi.getAll(params: {'limit': 1}),
        if (isAdmin) _userApi.getAll(params: {'limit': 1000}),
      ]);

      final dishTotal =
          results[0].data['total'] ??
          (results[0].data['data'] as List?)?.length ??
          0;
      final orderTotal =
          results[1].data['total'] ??
          (results[1].data['data'] as List?)?.length ??
          0;
      final resvTotal =
          results[2].data['total'] ??
          (results[2].data['data'] as List?)?.length ??
          0;
      int userTotal = 0;
      if (isAdmin && results.length > 3) {
        final rawUsers = results[3].data['data'] ?? results[3].data;
        if (rawUsers is List) userTotal = rawUsers.length;
      }

      if (!mounted) return;
      setState(() {
        _totalDishes = dishTotal is int
            ? dishTotal
            : (dishTotal as num).toInt();
        _totalOrders = orderTotal is int
            ? orderTotal
            : (orderTotal as num).toInt();
        _totalResv = resvTotal is int ? resvTotal : (resvTotal as num).toInt();
        _totalUsers = userTotal;
        _loadingStats = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
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
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (mounted) {
      await context.read<UserProvider>().logout();
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final userName = userProvider.userName;
        final isAdmin = userProvider.isAdmin;

        return Scaffold(
          backgroundColor: AppColors.gray50,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Restaurant Manager',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isAdmin ? 'Quản trị viên' : 'Nhân viên',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(userName, isAdmin),
                  const SizedBox(height: 20),
                  const Text(
                    'Thống kê',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatsGrid(isAdmin),
                  const SizedBox(height: 24),
                  const Text(
                    'Quản lý',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNavMenu(isAdmin),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(String userName, bool isAdmin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào mừng, $userName!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hệ thống quản lý nhà hàng',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isAdmin) {
    final stats = [
      _StatItem(
        'Tổng món ăn',
        _totalDishes,
        Icons.restaurant_menu,
        AppColors.primary,
      ),
      _StatItem(
        'Đơn hàng',
        _totalOrders,
        Icons.receipt_long,
        AppColors.green700,
      ),
      _StatItem(
        'Đặt bàn',
        _totalResv,
        Icons.calendar_today,
        const Color(0xFFF59E0B),
      ),
      if (isAdmin)
        _StatItem('Người dùng', _totalUsers, Icons.people, AppColors.secondary),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) {
        final s = stats[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: s.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(s.icon, color: s.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _loadingStats
                        ? SizedBox(
                            width: 32,
                            height: 18,
                            child: LinearProgressIndicator(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            '${s.value}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: s.color,
                            ),
                          ),
                    Text(
                      s.label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavMenu(bool isAdmin) {
    final items = [
      _NavItem(
        Icons.restaurant_menu,
        'Món ăn',
        'Quản lý thực đơn',
        RouteNames.dishes,
        AppColors.primary,
      ),
      _NavItem(
        Icons.receipt_long,
        'Đơn hàng',
        'Xem & tạo đơn hàng',
        RouteNames.orders,
        AppColors.green700,
      ),
      _NavItem(
        Icons.calendar_today,
        'Đặt bàn',
        'Quản lý đặt bàn',
        RouteNames.reservations,
        const Color(0xFFF59E0B),
      ),
      if (isAdmin) ...[
        _NavItem(
          Icons.category,
          'Danh mục',
          'Phân loại món ăn',
          RouteNames.categories,
          AppColors.secondary,
        ),
        _NavItem(
          Icons.inventory_2,
          'Kho hàng',
          'Nguyên liệu & nhập kho',
          RouteNames.inventory,
          const Color(0xFF0284C7),
        ),
        _NavItem(
          Icons.people,
          'Người dùng',
          'Quản lý tài khoản',
          RouteNames.users,
          AppColors.primary700,
        ),
      ],
    ];
    return Column(children: items.map(_navCard).toList());
  }

  Widget _navCard(_NavItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, color: item.color, size: 22),
        ),
        title: Text(
          item.label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.gray900,
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.gray600),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
        onTap: () => context.push(item.route),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _NavItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  final Color color;
  const _NavItem(this.icon, this.label, this.subtitle, this.route, this.color);
}
