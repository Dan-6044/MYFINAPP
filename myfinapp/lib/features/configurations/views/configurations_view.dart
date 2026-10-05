import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../currencies/controllers/currency_controller.dart';
import '../../currencies/views/currency_form_page.dart';
import '../../financial_periods/controllers/financial_period_controller.dart';
import '../../financial_periods/views/financial_period_form_page.dart';
import '../../financial_periods/views/close_financial_period_page.dart';
import '../../main_heads/controllers/main_head_controller.dart';
import '../../main_heads/views/main_head_form_page.dart';
import '../../subheads/controllers/subhead_controller.dart';
import '../../subheads/views/subhead_form_page.dart';
import '../../accounts/controllers/account_controller.dart';
import '../../accounts/views/account_form_page.dart';
import '../../transaction_types/controllers/transaction_type_controller.dart';
import '../../transaction_types/views/transaction_type_form_page.dart';
import '../../transaction_types/views/transaction_types_view.dart';
import '../../users/controllers/user_controller.dart';
import '../../users/views/user_form_page.dart';
import '../../users/views/users_view.dart';
import '../../../modules/auth/controllers/auth_controller.dart';
import '../models/config_menu_item.dart';

class ConfigurationsView extends StatefulWidget {
  const ConfigurationsView({super.key});

  @override
  State<ConfigurationsView> createState() => _ConfigurationsViewState();
}

class _ConfigurationsViewState extends State<ConfigurationsView> {
  static const _menuItems = <ConfigMenuItem>[
    ConfigMenuItem(
      id: 'financial_periods',
      title: 'Financial Periods',
      icon: Icons.calendar_month_rounded,
    ),
    ConfigMenuItem(id: 'main_heads', title: 'Main Heads', icon: Icons.account_balance_rounded),
    ConfigMenuItem(id: 'subheads', title: 'Subheads', icon: Icons.layers_rounded),
    ConfigMenuItem(
      id: 'chart_of_accounts',
      title: 'Chart of Account',
      icon: Icons.account_tree_rounded,
    ),
    ConfigMenuItem(
      id: 'currencies',
      title: 'Currencies',
      icon: Icons.currency_exchange_rounded,
    ),
    ConfigMenuItem(
      id: 'transaction_types',
      title: 'Transaction Types',
      icon: Icons.swap_horiz_rounded,
    ),
    ConfigMenuItem(
      id: 'transaction_rules',
      title: 'Exchange Rate Entry',
      icon: Icons.rule_rounded,
    ),
    ConfigMenuItem(id: 'users', title: 'Users', icon: Icons.people_rounded),
    ConfigMenuItem(
      id: 'roles_permissions',
      title: 'Roles & Permissions',
      icon: Icons.admin_panel_settings_rounded,
    ),
    ConfigMenuItem(
      id: 'general_setups',
      title: 'General Setups',
      icon: Icons.settings_applications_rounded,
    ),
  ];

  var _selectedId = 'financial_periods';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedItem = _menuItems.firstWhere(
      (item) => item.id == _selectedId,
      orElse: () => _menuItems.first,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0E0E0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF3D2C2C)),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          selectedItem.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3D2C2C),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF3D2C2C)),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      drawer: _ConfigDrawer(
        items: _menuItems,
        selectedId: _selectedId,
        onSelected: (id) {
          setState(() => _selectedId = id);
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildContent(selectedItem.id)),
            const _ConfigFooter(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPressed,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _onAddPressed() async {
    switch (_selectedId) {
      case 'financial_periods':
        final result = await Get.to(() => const FinancialPeriodFormPage());
        if (result != null && mounted) {
          try {
            final controller = Get.find<FinancialPeriodController>();
            await controller.createPeriod(result);
            Get.snackbar(
              'Success',
              'Financial period created successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString().replaceFirst('Exception: ', ''),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE53935),
              colorText: Colors.white,
            );
          }
        }
        break;
      case 'main_heads':
        final result = await Get.to(() => const MainHeadFormPage());
        if (result == true) {
          try {
            final controller = Get.find<MainHeadController>();
            await controller.loadMainHeads();
            Get.snackbar(
              'Success',
              'Main Head created successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString().replaceFirst('Exception: ', ''),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE53935),
              colorText: Colors.white,
            );
          }
        }
        break;
      case 'subheads':
        final result = await Get.to(() => const SubheadFormPage());
        if (result == true) {
          try {
            final controller = Get.find<SubheadController>();
            await controller.loadSubheads();
            Get.snackbar(
              'Success',
              'Subhead created successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString().replaceFirst('Exception: ', ''),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE53935),
              colorText: Colors.white,
            );
          }
        }
        break;
      case 'chart_of_accounts':
        final result = await Get.to(() => const AccountFormPage());
        if (result == true) {
          try {
            final controller = Get.find<AccountController>();
            await controller.loadAccounts();
            Get.snackbar(
              'Success',
              'Account created successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString().replaceFirst('Exception: ', ''),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE53935),
              colorText: Colors.white,
            );
          }
        }
        break;
      case 'currencies':
        final result = await Get.to(() => const CurrencyFormPage());
        if (result == true) {
          try {
            final controller = Get.find<CurrencyController>();
            await controller.loadCurrencies();
            Get.snackbar(
              'Success',
              'Currency created successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString().replaceFirst('Exception: ', ''),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE53935),
              colorText: Colors.white,
            );
          }
        }
        break;
      case 'transaction_types':
        final result = await Get.to(() => const TransactionTypeFormPage());
        if (result == true) {
          try {
            final controller = Get.find<TransactionTypeController>();
            await controller.loadTransactionTypes();
            Get.snackbar(
              'Success',
              'Transaction type created successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString().replaceFirst('Exception: ', ''),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE53935),
              colorText: Colors.white,
            );
          }
        }
        break;
      case 'transaction_rules':
        Get.snackbar(
          'Coming soon',
          'Add Exchange Rate Entry will be available soon.',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'users':
        final result = await Get.to(() => const UserFormPage());
        if (result == true) {
          try {
            final controller = Get.find<UserController>();
            await controller.loadUsers();
            Get.snackbar(
              'Success',
              'User created successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF4CAF50),
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString().replaceFirst('Exception: ', ''),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE53935),
              colorText: Colors.white,
            );
          }
        }
        break;
      default:
        Get.snackbar(
          'Coming soon',
          'Add ${_menuItems.firstWhere((item) => item.id == _selectedId).title} will be available soon.',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  Widget _buildContent(String id) {
    switch (id) {
      case 'financial_periods':
        return const _ConfigFinancialPeriodsPage();
      case 'main_heads':
        return const _ConfigMainHeadsPage();
      case 'subheads':
        return const _ConfigSubheadsPage();
      case 'chart_of_accounts':
        return const _ConfigChartOfAccountsPage();
      case 'currencies':
        return const _ConfigCurrenciesPage();
      case 'transaction_types':
        return const TransactionTypesView();
      case 'transaction_rules':
        return ConfigPlaceholderList(
          title: 'Exchange Rate Entry',
          onAdd: _onAddPressed,
        );
      case 'users':
        return const UsersView();
      default:
        return ConfigPlaceholderList(
          title: _menuItems.firstWhere((item) => item.id == id).title,
          onAdd: _onAddPressed,
        );
    }
  }
}

class _ConfigFinancialPeriodsPage extends StatelessWidget {
  const _ConfigFinancialPeriodsPage();

  String _formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _monthShort(dateTime.month);
    final year = dateTime.year;
    return '$day $month $year';
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Color _statusBackground(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFFFEBEE);
    }
  }

  Color _statusBorder(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFFE04057);
    }
  }

  Color _statusText(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFFC62828);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<FinancialPeriodController>();
      if (controller.isLoading.value && controller.periods.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final error = controller.errorMessage.value;
      if (error != null && error.isNotEmpty && controller.periods.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'Unable to load financial periods',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Please check your connection and try again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.loadPeriods,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.periods.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'No Financial Periods',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'No financial periods have been created yet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadPeriods,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.periods.length,
          itemBuilder: (context, index) {
            final period = controller.periods[index];
            final startFormatted = _formatDate(period.startDate);
            final endFormatted = _formatDate(period.endDate);

            return _ConfigListItem(
              title: period.periodName,
              subtitle: '${period.periodCode}\n$startFormatted - $endFormatted',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (period.isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7EF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                      ),
                      child: Text(
                        'CURRENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBackground(period.status),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _statusBorder(period.status), width: 1),
                    ),
                    child: Text(
                      period.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusText(period.status),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Theme(
                    data: Theme.of(context).copyWith(
                      popupMenuTheme: PopupMenuThemeData(
                        color: const Color(0xFFF4793A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, size: 18, color: const Color(0xFFF4793A)),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Get.to(
                            () => FinancialPeriodFormPage(period: period),
                          );
                          if (result == true) {
                            Get.find<FinancialPeriodController>().loadPeriods(
                              userId: Get.find<AuthController>().userID.value,
                            );
                            Get.snackbar(
                              'Success',
                              'Financial period updated successfully.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF4CAF50),
                              colorText: Colors.white,
                            );
                          }
                        }
                        if (value == 'close') {
                          await Get.to(() => CloseFinancialPeriodPage(period: period));
                          Get.find<FinancialPeriodController>().loadPeriods(
                            userId: Get.find<AuthController>().userID.value,
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                              const SizedBox(width: 12),
                              const Text('Edit FY', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        if (period.status == 'OPEN')
                          PopupMenuItem(
                            value: 'close',
                            child: Row(
                              children: [
                                Icon(Icons.lock_clock_rounded, size: 18, color: Colors.white),
                                const SizedBox(width: 12),
                                const Text('Close FY', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

class _ConfigMainHeadsPage extends StatelessWidget {
  const _ConfigMainHeadsPage();

  String _formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _monthShort(dateTime.month);
    final year = dateTime.year;
    return '$day $month $year';
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<MainHeadController>();
      if (controller.isLoading.value && controller.mainHeads.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final error = controller.errorMessage.value;
      if (error != null && error.isNotEmpty && controller.mainHeads.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'Unable to load main heads',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Please check your connection and try again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.loadMainHeads,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.mainHeads.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'No Main Heads',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'No main heads have been created yet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadMainHeads,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.mainHeads.length,
          itemBuilder: (context, index) {
            final mainHead = controller.mainHeads[index];
            final createdAtFormatted = _formatDate(mainHead.createdAt);

            return _ConfigListItem(
              title: mainHead.mainHeadName,
              subtitle: '${mainHead.mainHeadCode}\n${mainHead.accountingType} • $createdAtFormatted',
              trailing: Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: PopupMenuThemeData(
                    color: const Color(0xFFF4793A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 18, color: const Color(0xFFF4793A)),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Get.to(
                        () => MainHeadFormPage(mainHead: mainHead),
                      );
                      if (result == true) {
                        Get.find<MainHeadController>().loadMainHeads();
                        Get.snackbar(
                          'Success',
                          'Main Head updated successfully.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF4CAF50),
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 12),
                          const Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _ConfigSubheadsPage extends StatelessWidget {
  const _ConfigSubheadsPage();

  String _formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _monthShort(dateTime.month);
    final year = dateTime.year;
    return '$day $month $year';
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<SubheadController>();
      if (controller.isLoading.value && controller.subheads.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final error = controller.errorMessage.value;
      if (error != null && error.isNotEmpty && controller.subheads.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'Unable to load subheads',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Please check your connection and try again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.loadSubheads,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.subheads.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.layers_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'No Subheads',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'No subheads have been created yet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadSubheads,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.subheads.length,
          itemBuilder: (context, index) {
            final subhead = controller.subheads[index];
            final createdAtFormatted = _formatDate(subhead.createdAt);
            final mainHeadName = subhead.mainHead.mainHeadName;

            return _ConfigListItem(
              title: subhead.subheadName,
              subtitle: '${subhead.subheadCode}\n$mainHeadName • $createdAtFormatted',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: subhead.isActive ? const Color(0xFFFFF7EF) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: subhead.isActive ? const Color(0xFFF4793A) : const Color(0xFFBDBDBD),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      subhead.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subhead.isActive ? const Color(0xFFF4793A) : const Color(0xFF757575),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: subhead.isActive,
                    onChanged: (value) async {
                      if (value == subhead.isActive) return;
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: Row(
                            children: [
                              Icon(
                                value
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                size: 22,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  value ? 'Activate Subhead' : 'Deactivate Subhead',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subhead.subheadName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF3D2C2C),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                value
                                    ? 'Are you sure you want to activate this subhead?'
                                    : 'Are you sure you want to deactivate this subhead?',
                                style: const TextStyle(color: Color(0xFF8C7B7B)),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Get.back(result: true),
                              child: Text(value ? 'Activate' : 'Deactivate'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      try {
                        await controller.setActiveStatus(subhead.subheadID, value);
                      } catch (e) {
                        if (context.mounted) {
                          Get.snackbar(
                            'Error',
                            e.toString().replaceFirst('Exception: ', ''),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFFE53935),
                            colorText: Colors.white,
                          );
                        }
                      }
                    },
                    activeThumbColor: const Color(0xFFF4793A),
                    activeTrackColor: const Color(0xFFFFF7EF),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFE0E0E0),
                  ),
                  const SizedBox(width: 8),
                  Theme(
                    data: Theme.of(context).copyWith(
                      popupMenuTheme: PopupMenuThemeData(
                        color: const Color(0xFFF4793A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, size: 18, color: const Color(0xFFF4793A)),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Get.to(
                            () => SubheadFormPage(subhead: subhead),
                          );
                          if (result == true) {
                            Get.find<SubheadController>().loadSubheads();
                            Get.snackbar(
                              'Success',
                              'Subhead updated successfully.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF4CAF50),
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                              const SizedBox(width: 12),
                              const Text('Edit', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

class _ConfigChartOfAccountsPage extends StatelessWidget {
  const _ConfigChartOfAccountsPage();

  String _formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _monthShort(dateTime.month);
    final year = dateTime.year;
    return '$day $month $year';
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<AccountController>();
      if (controller.isLoading.value && controller.accounts.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final error = controller.errorMessage.value;
      if (error != null && error.isNotEmpty && controller.accounts.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'Unable to load chart of accounts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Please check your connection and try again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.loadAccounts,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.accounts.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_tree_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'No Chart of Accounts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'No accounts have been created yet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadAccounts,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.accounts.length,
          itemBuilder: (context, index) {
            final account = controller.accounts[index];
            final createdAtFormatted = _formatDate(account.createdAt);
            final subheadName = account.subhead.subheadName;
            final currency = account.currency;
            final currencyDisplay = currency != null
                ? '${currency.currencyCode}'
                : 'No Currency';

            return _ConfigListItem(
              title: '${account.coaCode} - ${account.coaName}',
              subtitle: '$subheadName • $currencyDisplay • $createdAtFormatted',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: account.isActive ? const Color(0xFFFFF7EF) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: account.isActive ? const Color(0xFFF4793A) : const Color(0xFFBDBDBD),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      account.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: account.isActive ? const Color(0xFFF4793A) : const Color(0xFF757575),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: account.isActive,
                    onChanged: (value) async {
                      if (value == account.isActive) return;
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: Row(
                            children: [
                              Icon(
                                value ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: 22,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  value ? 'Activate Account' : 'Deactivate Account',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.coaName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF3D2C2C),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                value
                                    ? 'Are you sure you want to activate this account?'
                                    : 'Are you sure you want to deactivate this account?',
                                style: const TextStyle(color: Color(0xFF8C7B7B)),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Get.back(result: true),
                              child: Text(value ? 'Activate' : 'Deactivate'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      try {
                        await controller.setActiveStatus(account.coaID, value);
                      } catch (e) {
                        if (context.mounted) {
                          Get.snackbar(
                            'Error',
                            e.toString().replaceFirst('Exception: ', ''),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFFE53935),
                            colorText: Colors.white,
                          );
                        }
                      }
                    },
                    activeThumbColor: const Color(0xFFF4793A),
                    activeTrackColor: const Color(0xFFFFF7EF),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFE0E0E0),
                  ),
                  const SizedBox(width: 8),
                  Theme(
                    data: Theme.of(context).copyWith(
                      popupMenuTheme: PopupMenuThemeData(
                        color: const Color(0xFFF4793A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, size: 18, color: const Color(0xFFF4793A)),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Get.to(
                            () => AccountFormPage(account: account),
                          );
                          if (result == true) {
                            Get.find<AccountController>().loadAccounts();
                            Get.snackbar(
                              'Success',
                              'Account updated successfully.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF4CAF50),
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                              const SizedBox(width: 12),
                              const Text('Edit', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

class _ConfigCurrenciesPage extends StatelessWidget {
  const _ConfigCurrenciesPage();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<CurrencyController>();
      if (controller.isLoading.value && controller.currencies.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final error = controller.errorMessage.value;
      if (error != null && error.isNotEmpty && controller.currencies.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'Unable to load currencies',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Please check your connection and try again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.loadCurrencies,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.currencies.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.currency_exchange_rounded, size: 40, color: Color(0xFFD6C8C0)),
                const SizedBox(height: 12),
                Text(
                  'No Currencies',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'No currencies have been created yet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadCurrencies,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.currencies.length,
          itemBuilder: (context, index) {
            final currency = controller.currencies[index];
            final symbol = currency.currencySymbol ?? '-';

            return _ConfigListItem(
              title: '${currency.currencyCode} - ${currency.currencyName}',
              subtitle: 'Symbol: $symbol • Base: ${currency.isBaseCurrency ? 'Yes' : 'No'}',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: currency.isActive ? const Color(0xFFFFF7EF) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: currency.isActive ? const Color(0xFFF4793A) : const Color(0xFFBDBDBD),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      currency.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: currency.isActive ? const Color(0xFFF4793A) : const Color(0xFF757575),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: currency.isActive,
                    onChanged: (value) async {
                      if (value == currency.isActive) return;
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: Row(
                            children: [
                              Icon(
                                value ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: 22,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  value ? 'Activate Currency' : 'Deactivate Currency',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.currencyName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF3D2C2C),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                value
                                    ? 'Are you sure you want to activate this currency?'
                                    : 'Are you sure you want to deactivate this currency?',
                                style: const TextStyle(color: Color(0xFF8C7B7B)),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Get.back(result: true),
                              child: Text(value ? 'Activate' : 'Deactivate'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      try {
                        await controller.setActiveStatus(currency.currencyID, value);
                      } catch (e) {
                        if (context.mounted) {
                          Get.snackbar(
                            'Error',
                            e.toString().replaceFirst('Exception: ', ''),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFFE53935),
                            colorText: Colors.white,
                          );
                        }
                      }
                    },
                    activeThumbColor: const Color(0xFFF4793A),
                    activeTrackColor: const Color(0xFFFFF7EF),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFE0E0E0),
                  ),
                  const SizedBox(width: 8),
                  Theme(
                    data: Theme.of(context).copyWith(
                      popupMenuTheme: PopupMenuThemeData(
                        color: const Color(0xFFF4793A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, size: 18, color: const Color(0xFFF4793A)),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Get.to(
                            () => CurrencyFormPage(currency: currency),
                          );
                          if (result == true) {
                            Get.find<CurrencyController>().loadCurrencies();
                            Get.snackbar(
                              'Success',
                              'Currency updated successfully.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF4CAF50),
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                              const SizedBox(width: 12),
                              const Text('Edit', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

class _ConfigDrawer extends StatelessWidget {
  final List<ConfigMenuItem> items;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _ConfigDrawer({
    required this.items,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.72,
      child: Container(
        color: const Color(0xFFF4793A),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                child: Text(
                  'Configuration',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(color: Color(0x33FFFFFF), height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.id == selectedId;
                    return _DrawerTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onSelected(item.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final ConfigMenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? const Color(0x26FFFFFF) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              item.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigFooter extends StatelessWidget {
  const _ConfigFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Text(
        'Powered by MDM Solutions',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF4A90E2),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ConfigListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _ConfigListItem({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0E6DC), width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3D2C2C),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8C7B7B),
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class ConfigPlaceholderList extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const ConfigPlaceholderList({
    super.key,
    required this.title,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 48, color: const Color(0xFFD6C8C0)),
            const SizedBox(height: 16),
            Text(
              'No $title found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3D2C2C),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This module is not yet configured.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8C7B7B),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
