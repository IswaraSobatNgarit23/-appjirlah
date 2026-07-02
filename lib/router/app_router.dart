import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/main_screen.dart';
import '../screens/chart_detail_screen.dart';

/// Provider untuk GoRouter agar bisa direferensikan secara global
/// atau untuk fitur redirect berbasis state/auth nantinya.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'chart',
            name: 'chartDetail',
            builder: (context, state) => const ChartDetailScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan: ${state.error}'),
      ),
    ),
  );
});
