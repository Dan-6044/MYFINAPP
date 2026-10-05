import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/theme/app_theme.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyFinApp());
}

class MyFinApp extends StatelessWidget {
  const MyFinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MYFIN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      initialRoute: AppPages.initial,
    );
  }
}
