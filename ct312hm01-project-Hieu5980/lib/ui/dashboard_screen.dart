import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Themes/app_colors.dart';
import '../services/api/dishes_api.dart';
import '../services/api/orders_api.dart';
import '../services/api/reservations_api.dart';
import '../services/api/user_api.dart';
import '../routes/app_routes.dart';
import '../routes/route_names.dart';
import '../main.dart' show routeObserver;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  final _storage = const FlutterSecureStorage();
  final _dishesApi = DishesAPI();
  final _ordersApi = OrdersAPI();
  final _resApi = ReservationsAPI();
  final _userApi = UserAPI();

  String _userName = '';
  String _userRole = '';
  bool _isAdmin = false;

  int _totalDishes = 0;
  int _totalOrders = 0;
  int _totalResv = 0;
  int _totalUsers = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadStats();
  }

  @override
  void didPush() {}

  Future<void> _loadUser() async {
    final name = await _storage.read(key: 'user_name');
    final role = await _storage.read(key: 'user_role');
    setState(() {
      _userName = name ?? 'Người dùng';
      _userRole = role ?? 'user';
      _isAdmin = role == 'admin';
    });
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final results = await Future.wait([
        _dishesApi.getAll(params: {'limit': 1}),
        _ordersApi.getAll(params: {'limit': 1}),
        _resApi.getAll(params: {'limit': 1}),
        if (_isAdmin) _userApi.getAll(params: {'limit': 1000}),
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
      if (_isAdmin && results.length > 3) {
        final rawUsers = results[3].data['data'] ?? results[3].data;
        if (rawUsers is List) {
          userTotal = rawUsers.length;
        }
      }

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
      setState(() => _loadingStats = false);
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
    await _storage.deleteAll();
    if (mounted) {
      AppRoutes.navigateAndReplace(context, RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _isAdmin ? 'Quản trị viên' : 'Nhân viên',
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
              _buildWelcomeCard(),
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
              _buildStatsGrid(),
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
              _buildNavMenu(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
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
                  'Chào mừng, $_userName!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hệ thống quản lý nhà hàng',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
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
                _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
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

  Widget _buildStatsGrid() {
    final stats = [
      _StatItem(
        label: 'Tổng món ăn',
        value: _totalDishes,
        icon: Icons.restaurant_menu,
        color: AppColors.primary,
      ),
      _StatItem(
        label: 'Đơn hàng',
        value: _totalOrders,
        icon: Icons.receipt_long,
        color: AppColors.green700,
      ),
      _StatItem(
        label: 'Đặt bàn',
        value: _totalResv,
        icon: Icons.calendar_today,
        color: const Color(0xFFF59E0B),
      ),
      if (_isAdmin)
        _StatItem(
          label: 'Người dùng',
          value: _totalUsers,
          icon: Icons.people,
          color: AppColors.secondary,
        ),
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

  Widget _buildNavMenu() {
    final items = [
      _NavItem(
        icon: Icons.restaurant_menu,
        label: 'Món ăn',
        subtitle: 'Quản lý thực đơn',
        route: RouteNames.dishes,
        color: AppColors.primary,
      ),
      _NavItem(
        icon: Icons.receipt_long,
        label: 'Đơn hàng',
        subtitle: 'Xem & tạo đơn hàng',
        route: RouteNames.orders,
        color: AppColors.green700,
      ),
      _NavItem(
        icon: Icons.calendar_today,
        label: 'Đặt bàn',
        subtitle: 'Quản lý đặt bàn',
        route: RouteNames.reservations,
        color: const Color(0xFFF59E0B),
      ),
      if (_isAdmin) ...[
        _NavItem(
          icon: Icons.category,
          label: 'Danh mục',
          subtitle: 'Phân loại món ăn',
          route: RouteNames.categories,
          color: AppColors.secondary,
        ),
        _NavItem(
          icon: Icons.inventory_2,
          label: 'Kho hàng',
          subtitle: 'Nguyên liệu & nhập kho',
          route: RouteNames.inventory,
          color: const Color(0xFF0284C7),
        ),
        _NavItem(
          icon: Icons.people,
          label: 'Người dùng',
          subtitle: 'Quản lý tài khoản',
          route: RouteNames.users,
          color: AppColors.primary700,
        ),
      ],
    ];

    return Column(children: items.map((item) => _navCard(item)).toList());
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
        onTap: () => AppRoutes.navigate(context, item.route),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _NavItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  final Color color;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.color,
  });
}
