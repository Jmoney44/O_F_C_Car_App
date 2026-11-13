import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ofc_luxury/app.dart';
import 'package:ofc_luxury/data/demo/demo_repositories.dart';
import 'package:ofc_luxury/models/car_order.dart';
import 'package:ofc_luxury/models/car.dart';
import 'package:ofc_luxury/providers.dart';

void main() {
  testWidgets('sign in, open a car and request a reservation', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final repositories = demoRepositories();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoriesProvider.overrideWithValue(repositories)],
        child: const OfcApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Signed out, so the app opens on the sign-in screen and validates input.
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'jo@ofc.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Jo'), findsOneWidget);
    expect(find.text('Featured'), findsOneWidget);

    await tester.tap(find.text('2024 Mercedes-Benz S 580 e').first);
    await tester.pumpAndSettle();
    expect(find.text('Make an offer'), findsOneWidget);

    await tester.tap(find.text('Reserve'));
    await tester.pumpAndSettle();
    final submit = find.textContaining('Request reservation');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Reservation requested'), findsOneWidget);

    final orders = await repositories.orders.watchAllOrders().first;
    expect(orders.single.carTitle, '2024 Mercedes-Benz S 580 e');
    expect(orders.single.status, OrderStatus.pending);

    // The showroom confirming the order takes the car off sale.
    await repositories.orders.updateStatus(
      orders.single,
      OrderStatus.confirmed,
    );
    final car = await repositories.cars.getCar(orders.single.carId);
    expect(car!.status, CarStatus.reserved);
  });

  testWidgets('only admins can reach the admin area', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final repositories = demoRepositories();
    await repositories.auth.signIn(email: 'jo@ofc.com', password: 'x');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoriesProvider.overrideWithValue(repositories)],
        child: const OfcApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Admin area'), findsNothing);

    await repositories.auth.signIn(email: 'admin@ofc.com', password: 'x');
    await tester.pumpAndSettle();
    expect(find.text('Admin area'), findsOneWidget);

    await tester.tap(find.text('Admin area'));
    await tester.pumpAndSettle();
    expect(find.text('Stock and QR codes'), findsOneWidget);
  });
}
