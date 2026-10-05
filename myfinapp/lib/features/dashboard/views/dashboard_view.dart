import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/auth/controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/myfin_module_tile.dart';
import '../../../core/widgets/myfin_search_bar.dart';
import '../../../core/widgets/myfin_page_header.dart';
import '../../../core/widgets/myfin_footer.dart';
import '../../dashboard/models/myfin_module.dart';

class DashboardView extends GetView<AuthController> {
  const DashboardView({super.key});

  static const _modules = <MyfinModule>[
    MyfinModule(
      id: 'configurations',
      title: 'Configurations',
      description: 'System and application setup',
      icon: Icons.settings_rounded,
      route: AppRoutes.configurations,
      keywords: ['config', 'settings', 'setup', 'system'],
    ),
    MyfinModule(
      id: 'accounting',
      title: 'Accounting',
      description: 'Financial transactions and management',
      icon: Icons.account_balance_wallet_rounded,
      route: AppRoutes.accounting,
      keywords: ['account', 'transactions', 'financial', 'bookkeeping'],
    ),
    MyfinModule(
      id: 'reports',
      title: 'Reports',
      description: 'Financial reports and analysis',
      icon: Icons.bar_chart_rounded,
      route: AppRoutes.reports,
      keywords: ['report', 'analysis', 'financial', 'statements'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'MYFIN',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurface),
            onSelected: (value) async {
              if (value == 'logout') {
                await controller.logout();
                Get.offAllNamed(AppRoutes.login);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyfinPageHeader(
                  title: controller.firstName.value.trim().isNotEmpty
                      ? 'Welcome, ${controller.firstName.value.trim()}'
                      : 'Welcome to MYFIN',
                  subtitle: 'Personal Finance',
                  titleColor: const Color(0xFF5B9BD5),
                ),
                const SizedBox(height: 16),
                _LauncherSearchAndGrid(modules: _modules),
                const SizedBox(height: 24),
                const MyfinFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LauncherSearchAndGrid extends StatefulWidget {
  final List<MyfinModule> modules;

  const _LauncherSearchAndGrid({required this.modules});

  @override
  State<_LauncherSearchAndGrid> createState() => _LauncherSearchAndGridState();
}

class _LauncherSearchAndGridState extends State<_LauncherSearchAndGrid> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _filter(_query);
    return Column(
      children: [
        MyfinSearchBar(
          onChanged: (value) => setState(() => _query = value),
          onClear: () => setState(() => _query = ''),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 500 ? 3 : 2;
            if (filtered.isEmpty) {
              return Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.search_off_rounded, size: 40, color: const Color(0xFFD6C8C0)),
                  const SizedBox(height: 12),
                  Text(
                    'No modules found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3D2C2C),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try another search.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8C7B7B),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final module = filtered[index];
                return MyfinModuleTile(
                  module: module,
                  onTap: () => Get.toNamed(module.route),
                );
              },
            );
          },
        ),
      ],
    );
  }

  List<MyfinModule> _filter(String query) {
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return widget.modules;
    return widget.modules.where((m) {
      final inTitle = m.title.toLowerCase().contains(lower);
      final inDescription = m.description.toLowerCase().contains(lower);
      final inKeywords = m.keywords.any((k) => k.contains(lower));
      return inTitle || inDescription || inKeywords;
    }).toList();
  }
}
