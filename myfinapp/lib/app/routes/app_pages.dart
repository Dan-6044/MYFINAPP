import 'package:get/get.dart';

import 'app_routes.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/authenticated_view.dart';
import '../../modules/connectivity/bindings/connectivity_binding.dart';
import '../../modules/connectivity/views/connectivity_view.dart';
import '../../features/currencies/bindings/currency_binding.dart';
import '../../features/currencies/views/currencies_view.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/configurations/bindings/configuration_binding.dart';
import '../../features/configurations/views/configurations_view.dart';
import '../../features/accounting/bindings/accounting_binding.dart';
import '../../features/accounting/views/accounting_view.dart';
import '../../features/reports/views/reports_view.dart';

class AppPages {
  static final initial = AppRoutes.login;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const AuthenticatedView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.connectivity,
      page: () => const ConnectivityView(),
      binding: ConnectivityBinding(),
    ),
    GetPage(
      name: AppRoutes.currencies,
      page: () => const CurrenciesView(),
      binding: CurrencyBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.configurations,
      page: () => const ConfigurationsView(),
      binding: ConfigurationBinding(),
    ),
    GetPage(
      name: AppRoutes.accounting,
      page: () => const AccountingView(),
      binding: AccountingBinding(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: AuthBinding(),
    ),
  ];
}
