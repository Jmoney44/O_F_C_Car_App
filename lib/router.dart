import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'features/account/account_screens.dart';
import 'features/admin/admin_cars_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/admin_orders_offers_screens.dart';
import 'features/admin/car_form_screen.dart';
import 'features/admin/car_qr_screen.dart';
import 'features/auth/auth_screens.dart';
import 'features/cars/browse_screen.dart';
import 'features/cars/car_details_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/home_shell.dart';
import 'features/offers/make_offer_screen.dart';
import 'features/offers/my_offers_screen.dart';
import 'features/orders/my_orders_screen.dart';
import 'features/orders/reserve_screen.dart';
import 'features/scan/scan_screen.dart';
import 'providers.dart';

const _signedOutRoutes = {'/sign-in', '/sign-up', '/forgot-password'};

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run the redirect whenever the user signs in or out, or their admin
  // role changes.
  final authChanges = ValueNotifier(0);
  ref.listen(currentUserProvider, (_, _) => authChanges.value++);
  ref.onDispose(authChanges.dispose);

  // Where the person was heading before being sent to sign in, e.g. a car
  // link opened from a QR code.
  String? pending;

  final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: authChanges,
    redirect: (context, state) {
      final auth = ref.read(currentUserProvider);
      final path = state.matchedLocation;
      final target = state.uri.toString();

      if (auth.isLoading && !auth.hasValue) {
        if (path != '/splash') pending ??= target;
        return path == '/splash' ? null : '/splash';
      }

      final user = auth.value;
      if (user == null) {
        if (_signedOutRoutes.contains(path)) return null;
        if (path != '/splash') pending ??= target;
        return '/sign-in';
      }

      if (path == '/splash' || _signedOutRoutes.contains(path)) {
        final destination = pending ?? '/home';
        pending = null;
        return destination;
      }
      pending = null;
      if (path.startsWith('/admin') && !user.isAdmin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _SplashScreen()),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/browse', builder: (_, _) => const BrowseScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (_, _) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (_, _) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      // The same path as the link inside each QR code.
      GoRoute(
        path: '/car/:id',
        builder: (_, state) =>
            CarDetailsScreen(carId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'offer',
            builder: (_, state) =>
                MakeOfferScreen(carId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'reserve',
            builder: (_, state) =>
                ReserveScreen(carId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(path: '/scan', builder: (_, _) => const ScanScreen()),
      GoRoute(path: '/orders', builder: (_, _) => const MyOrdersScreen()),
      GoRoute(path: '/offers', builder: (_, _) => const MyOffersScreen()),
      GoRoute(
        path: '/account/edit',
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, _) => const AdminDashboardScreen(),
        routes: [
          GoRoute(path: 'cars', builder: (_, _) => const AdminCarsScreen()),
          GoRoute(path: 'cars/new', builder: (_, _) => const CarFormScreen()),
          GoRoute(
            path: 'cars/:id/edit',
            builder: (_, state) =>
                CarFormScreen(carId: state.pathParameters['id']),
          ),
          GoRoute(
            path: 'cars/:id/qr',
            builder: (_, state) =>
                CarQrScreen(carId: state.pathParameters['id']!),
          ),
          GoRoute(path: 'orders', builder: (_, _) => const AdminOrdersScreen()),
          GoRoute(path: 'offers', builder: (_, _) => const AdminOffersScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FilledButton.tonal(
          onPressed: () => context.go('/home'),
          child: const Text('Page not found. Go home'),
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
