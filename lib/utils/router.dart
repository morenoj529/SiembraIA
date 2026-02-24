import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_state.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/register_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/plot_detail_screen.dart';
import '../ui/screens/edit_plot_screen.dart';
import '../ui/screens/new_visit_screen.dart';
import '../ui/screens/visit_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/plots/new',
        builder: (_, __) => const EditPlotScreen(),
      ),
      GoRoute(
        path: '/plots/edit/:id',
        builder: (_, state) =>
            EditPlotScreen(plotId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/plots/:id',
        builder: (_, state) =>
            PlotDetailScreen(plotId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/visits/new',
        builder: (_, state) => NewVisitScreen(
          plotId: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/visits/:id',
        builder: (_, state) =>
            VisitDetailScreen(visitId: state.pathParameters['id']!),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.error}')),
    ),
  );
});
