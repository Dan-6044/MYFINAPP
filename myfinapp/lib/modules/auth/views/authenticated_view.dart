import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../features/dashboard/views/dashboard_view.dart';

class AuthenticatedView extends GetView<AuthController> {
  const AuthenticatedView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardView();
  }
}
