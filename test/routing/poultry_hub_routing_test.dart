// Routing tests for every poultry hub button.
//
// Strategy: mirror the production route tree using labelled Text widgets so
// tests are fast (no providers, no asset loading) and purely verify that
// go_router resolves each path to the CORRECT handler.
//
// The critical regression being guarded: literal routes (invoice, inventory,
// houses) must NOT be matched as :flockId.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Mirror router
// ---------------------------------------------------------------------------

GoRouter _buildTestRouter(String initialLocation) => GoRouter(
      initialLocation: initialLocation,
      errorBuilder: (_, state) => Text('ERROR:${state.uri}'),
      routes: [
        GoRoute(
          path: '/livestock',
          builder: (_, _) => const Text('LivestockScreen'),
          routes: [
            GoRoute(
              path: 'poultry',
              builder: (_, _) => const Text('PoultryHubScreen'),
              routes: [
                // ── Literal routes FIRST — prevents :flockId eating them ───
                GoRoute(
                  path: 'flocks',
                  builder: (_, _) => const Text('PoultryScreen'),
                ),
                GoRoute(
                  path: 'new',
                  builder: (_, _) => const Text('AddFlockScreen'),
                ),
                GoRoute(
                  path: 'inventory',
                  builder: (_, _) => const Text('InventoryScreen'),
                  routes: [
                    GoRoute(
                      path: 'delivery/new',
                      builder: (_, _) => const Text('AddDeliveryScreen'),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'invoice',
                  builder: (_, _) => const Text('InvoiceScreen'),
                ),
                GoRoute(
                  path: 'houses',
                  builder: (_, _) => const Text('HouseAllocationScreen'),
                ),
                GoRoute(
                  path: 'vaccinations',
                  builder: (_, _) => const Text('VaccinationHubScreen'),
                ),
                GoRoute(
                  path: 'daily-records',
                  builder: (_, _) => const Text('PoultryFlockPickerScreen:daily-add'),
                ),
                GoRoute(
                  path: 'feed-phases-hub',
                  builder: (_, _) => const Text('PoultryFlockPickerScreen:feed-phases'),
                ),
                GoRoute(
                  path: 'health-events',
                  builder: (_, _) => const Text('HealthEventsHubScreen'),
                ),
                GoRoute(
                  path: 'financials-hub',
                  builder: (_, _) => const Text('PoultryFlockPickerScreen:financial'),
                ),
                GoRoute(
                  path: 'reports',
                  builder: (_, _) => const Text('PoultryReportsScreen'),
                ),
                // ── Parameterised route LAST ───────────────────────────────
                GoRoute(
                  path: ':flockId',
                  builder: (_, state) =>
                      Text('FlockDetailScreen:${state.pathParameters['flockId']}'),
                  routes: [
                    GoRoute(
                      path: 'daily/add',
                      builder: (_, state) =>
                          Text('AddDailyRecord:${state.pathParameters['flockId']}'),
                    ),
                    GoRoute(
                      path: 'harvest',
                      builder: (_, state) =>
                          Text('HarvestRecord:${state.pathParameters['flockId']}'),
                    ),
                    GoRoute(
                      path: 'feed-phases',
                      builder: (_, state) =>
                          Text('FeedPhases:${state.pathParameters['flockId']}'),
                      routes: [
                        GoRoute(
                          path: 'new',
                          builder: (_, state) =>
                              Text('AddFeedPhase:${state.pathParameters['flockId']}'),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'medications/new',
                      builder: (_, state) =>
                          Text('AddMedication:${state.pathParameters['flockId']}'),
                    ),
                    GoRoute(
                      path: 'financial',
                      builder: (_, state) =>
                          Text('FlockFinancial:${state.pathParameters['flockId']}'),
                    ),
                    GoRoute(
                      path: 'health/new',
                      builder: (_, state) =>
                          Text('AddDiseaseEvent:${state.pathParameters['flockId']}'),
                    ),
                    GoRoute(
                      path: 'biosecurity',
                      builder: (_, state) =>
                          Text('BiosecurityLog:${state.pathParameters['flockId']}'),
                    ),
                    GoRoute(
                      path: 'litter',
                      builder: (_, state) =>
                          Text('LitterManagement:${state.pathParameters['flockId']}'),
                    ),
                    GoRoute(
                      path: 'molt',
                      builder: (_, state) =>
                          Text('MoltManagement:${state.pathParameters['flockId']}'),
                    ),
                    GoRoute(
                      path: 'breeder-records',
                      builder: (_, state) =>
                          Text('BreederRecords:${state.pathParameters['flockId']}'),
                    ),
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) =>
                          Text('EditFlock:${state.pathParameters['flockId']}'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, String path) async {
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: _buildTestRouter(path)),
  );
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── Hub button routes ──────────────────────────────────────────────────────

  group('Hub button: Flock Manager', () {
    testWidgets('resolves to PoultryScreen', (t) async {
      await _pump(t, '/livestock/poultry/flocks');
      expect(find.text('PoultryScreen'), findsOneWidget);
    });
    testWidgets('resolves to PoultryScreen with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/flocks?species=poultry');
      expect(find.text('PoultryScreen'), findsOneWidget);
    });
  });

  group('Hub button: Add Flock', () {
    testWidgets('resolves to AddFlockScreen', (t) async {
      await _pump(t, '/livestock/poultry/new');
      expect(find.text('AddFlockScreen'), findsOneWidget);
    });
    testWidgets('resolves to AddFlockScreen with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/new?species=poultry');
      expect(find.text('AddFlockScreen'), findsOneWidget);
    });
  });

  group('Hub button: Inventory', () {
    testWidgets('resolves to InventoryScreen — NOT FlockDetailScreen', (t) async {
      await _pump(t, '/livestock/poultry/inventory');
      expect(find.text('InventoryScreen'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
    testWidgets('resolves to InventoryScreen with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/inventory?species=poultry');
      expect(find.text('InventoryScreen'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
  });

  group('Hub button: New Delivery', () {
    testWidgets('resolves to AddDeliveryScreen', (t) async {
      await _pump(t, '/livestock/poultry/inventory/delivery/new');
      expect(find.text('AddDeliveryScreen'), findsOneWidget);
    });
    testWidgets('resolves to AddDeliveryScreen with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/inventory/delivery/new?species=poultry');
      expect(find.text('AddDeliveryScreen'), findsOneWidget);
    });
  });

  group('Hub button: Invoice (critical regression)', () {
    testWidgets('resolves to InvoiceScreen — NOT FlockDetailScreen', (t) async {
      await _pump(t, '/livestock/poultry/invoice');
      expect(find.text('InvoiceScreen'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
    testWidgets('resolves to InvoiceScreen with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/invoice?species=poultry');
      expect(find.text('InvoiceScreen'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
    testWidgets('resolves to InvoiceScreen with ?flockId query', (t) async {
      await _pump(t, '/livestock/poultry/invoice?flockId=flock_001');
      expect(find.text('InvoiceScreen'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
  });

  group('Hub button: Houses', () {
    testWidgets('resolves to HouseAllocationScreen — NOT FlockDetailScreen', (t) async {
      await _pump(t, '/livestock/poultry/houses');
      expect(find.text('HouseAllocationScreen'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
    testWidgets('resolves to HouseAllocationScreen with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/houses?species=poultry');
      expect(find.text('HouseAllocationScreen'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
  });

  // ── Flock-level sub-routes (reached from FlockDetailScreen) ───────────────

  group('Flock sub-routes: :flockId captures real IDs', () {
    testWidgets('flock detail with real id', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123');
      expect(find.text('FlockDetailScreen:flock_abc123'), findsOneWidget);
    });
    testWidgets('daily record add passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/daily/add');
      expect(find.text('AddDailyRecord:flock_abc123'), findsOneWidget);
    });
    testWidgets('harvest passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/harvest');
      expect(find.text('HarvestRecord:flock_abc123'), findsOneWidget);
    });
    testWidgets('feed phases passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/feed-phases');
      expect(find.text('FeedPhases:flock_abc123'), findsOneWidget);
    });
    testWidgets('add feed phase passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/feed-phases/new');
      expect(find.text('AddFeedPhase:flock_abc123'), findsOneWidget);
    });
    testWidgets('add medication passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/medications/new');
      expect(find.text('AddMedication:flock_abc123'), findsOneWidget);
    });
    testWidgets('flock financial passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/financial');
      expect(find.text('FlockFinancial:flock_abc123'), findsOneWidget);
    });
    testWidgets('add disease event passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/health/new');
      expect(find.text('AddDiseaseEvent:flock_abc123'), findsOneWidget);
    });
    testWidgets('biosecurity passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/biosecurity');
      expect(find.text('BiosecurityLog:flock_abc123'), findsOneWidget);
    });
    testWidgets('litter passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/litter');
      expect(find.text('LitterManagement:flock_abc123'), findsOneWidget);
    });
    testWidgets('molt passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/molt');
      expect(find.text('MoltManagement:flock_abc123'), findsOneWidget);
    });
    testWidgets('breeder records passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/breeder-records');
      expect(find.text('BreederRecords:flock_abc123'), findsOneWidget);
    });
    testWidgets('edit flock passes flockId', (t) async {
      await _pump(t, '/livestock/poultry/flock_abc123/edit');
      expect(find.text('EditFlock:flock_abc123'), findsOneWidget);
    });
  });

  // ── Edge cases ─────────────────────────────────────────────────────────────

  group('Edge cases', () {
    testWidgets('completely unknown path shows error', (t) async {
      await _pump(t, '/livestock/poultry/unknown/very/deep');
      expect(find.textContaining('ERROR:'), findsOneWidget);
    });
    testWidgets('invoice with numeric-looking id is still InvoiceScreen', (t) async {
      // Verifies that even segment text like "invoice" is never hijacked
      await _pump(t, '/livestock/poultry/invoice?flockId=12345');
      expect(find.text('InvoiceScreen'), findsOneWidget);
    });
    testWidgets('hub path /livestock/poultry resolves to hub', (t) async {
      await _pump(t, '/livestock/poultry');
      expect(find.text('PoultryHubScreen'), findsOneWidget);
    });
  });

  // ── New hub button routes ──────────────────────────────────────────────────

  group('Hub button: Vaccination', () {
    testWidgets('resolves to VaccinationHubScreen — NOT FlockDetailScreen', (t) async {
      await _pump(t, '/livestock/poultry/vaccinations');
      expect(find.text('VaccinationHubScreen'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
    testWidgets('resolves to VaccinationHubScreen with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/vaccinations?species=poultry');
      expect(find.text('VaccinationHubScreen'), findsOneWidget);
    });
  });

  group('Hub button: Daily Records', () {
    testWidgets('resolves to picker — NOT FlockDetailScreen', (t) async {
      await _pump(t, '/livestock/poultry/daily-records');
      expect(find.text('PoultryFlockPickerScreen:daily-add'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
    testWidgets('resolves to picker with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/daily-records?species=poultry');
      expect(find.text('PoultryFlockPickerScreen:daily-add'), findsOneWidget);
    });
  });

  group('Hub button: Feed Phases Hub', () {
    testWidgets('resolves to picker — NOT FlockDetailScreen', (t) async {
      await _pump(t, '/livestock/poultry/feed-phases-hub');
      expect(find.text('PoultryFlockPickerScreen:feed-phases'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
    testWidgets('resolves to picker with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/feed-phases-hub?species=poultry');
      expect(find.text('PoultryFlockPickerScreen:feed-phases'), findsOneWidget);
    });
  });

  group('Hub button: Health Events (critical regression)', () {
    testWidgets('resolves to HealthEventsHubScreen — NOT FlockDetailScreen', (t) async {
      await _pump(t, '/livestock/poultry/health-events');
      expect(find.text('HealthEventsHubScreen'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
    testWidgets('resolves to HealthEventsHubScreen with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/health-events?species=poultry');
      expect(find.text('HealthEventsHubScreen'), findsOneWidget);
    });
  });

  group('Hub button: Financials Hub', () {
    testWidgets('resolves to picker — NOT FlockDetailScreen', (t) async {
      await _pump(t, '/livestock/poultry/financials-hub');
      expect(find.text('PoultryFlockPickerScreen:financial'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
    testWidgets('resolves to picker with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/financials-hub?species=poultry');
      expect(find.text('PoultryFlockPickerScreen:financial'), findsOneWidget);
    });
  });

  group('Hub button: Reports (critical regression)', () {
    testWidgets('resolves to PoultryReportsScreen — NOT FlockDetailScreen', (t) async {
      await _pump(t, '/livestock/poultry/reports');
      expect(find.text('PoultryReportsScreen'), findsOneWidget);
      expect(find.textContaining('FlockDetailScreen'), findsNothing);
    });
    testWidgets('resolves to PoultryReportsScreen with ?species query', (t) async {
      await _pump(t, '/livestock/poultry/reports?species=poultry');
      expect(find.text('PoultryReportsScreen'), findsOneWidget);
    });
  });
}
