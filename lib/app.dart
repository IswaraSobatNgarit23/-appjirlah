import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

/// Root widget aplikasi EWS Gunung Semeru.
/// 
/// Tidak lagi menerima parameter DataService karena sudah di-handle oleh Riverpod.
/// Menggunakan MaterialApp.router untuk mendukung GoRouter.
class EWSApp extends ConsumerWidget {
  const EWSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'EWS Gunung Semeru',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
