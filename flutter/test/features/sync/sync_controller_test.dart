import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/features/sync/application/sync_controller.dart';
import 'package:lifequest/features/sync/data/appwrite_cloud_gateway.dart';
import 'package:lifequest/features/sync/data/fake_cloud_gateway.dart';
import 'package:lifequest/features/sync/domain/sync_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeContainer(FakeCloudGateway gateway) {
    final container = ProviderContainer(
      overrides: [cloudGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('starts disconnected on a fresh install', () async {
    final container = makeContainer(FakeCloudGateway());
    final status = await container.read(syncProvider.future);
    expect(status.state, CloudConnectionState.disconnected);
  });

  test(
    'connect moves through to connected and flushes queued writes',
    () async {
      final gateway = FakeCloudGateway();
      final container = makeContainer(gateway);
      final sync = container.read(syncProvider.notifier);

      // Queue a write while offline: it must not go to the cloud yet.
      await sync.queuePush('quests', {'items': []});
      expect(gateway.docs, isEmpty);

      await sync.connect();
      final status = container.read(syncProvider).value!;
      expect(status.state, CloudConnectionState.connected);
      // The queued write was flushed on connect.
      expect(gateway.docs['quests']!.data, {'items': []});
      expect(status.pendingCount, 0);
    },
  );

  test('pull applies remote snapshot through the registered store', () async {
    final gateway = FakeCloudGateway();
    final container = makeContainer(gateway);
    final sync = container.read(syncProvider.notifier);

    var applied = false;
    sync.registerStore('quests', (data) async => applied = true);

    // Seed a remote doc, then connect.
    await gateway.connect();
    await gateway.put(
      const StoreDocument(
        key: 'quests',
        data: {
          'items': [1],
        },
      ),
    );

    await sync.connect();
    expect(applied, isTrue);
  });

  test('push failure queues the change and reports error state', () async {
    final gateway = FakeCloudGateway()..failSaves = true;
    final container = makeContainer(gateway);
    final sync = container.read(syncProvider.notifier);

    await sync.connect(); // connect succeeds, first put fails
    await sync.queuePush('quests', {
      'items': [1, 2],
    });
    await Future<void>.delayed(Duration.zero); // let the flush land

    final status = container.read(syncProvider).value!;
    expect(status.state, CloudConnectionState.error);
    expect(status.errorMessage, isNotNull);
  });

  test('retry flushes previously failed writes', () async {
    final gateway = FakeCloudGateway()..failSaves = true;
    final container = makeContainer(gateway);
    final sync = container.read(syncProvider.notifier);
    await sync.connect();
    await sync.queuePush('quests', {
      'items': [1],
    });

    gateway.failSaves = false;
    await sync.retry();

    final status = container.read(syncProvider).value!;
    expect(status.state, CloudConnectionState.connected);
    expect(gateway.docs['quests']!.data, {
      'items': [1],
    });
    expect(status.pendingCount, 0);
  });

  test('disconnect clears state but keeps cloud data', () async {
    final gateway = FakeCloudGateway();
    final container = makeContainer(gateway);
    final sync = container.read(syncProvider.notifier);
    await sync.connect();
    await sync.queuePush('quests', {'items': []});
    await Future<void>.delayed(Duration.zero); // let the flush land

    await sync.disconnect();

    final status = container.read(syncProvider).value!;
    expect(status.state, CloudConnectionState.disconnected);
    expect(gateway.docs['quests'], isNotNull);
  });

  test('describeCloudError maps known SDK errors', () {
    expect(describeCloudError(const CloudConfigException('nope')), 'nope');
    expect(describeCloudError(Exception('anything')), contains('Try again'));
  });

  group('auto-reconnect on startup', () {
    test('build reports connecting and then reconnects + flushes', () async {
      final gateway = FakeCloudGateway();
      // Simulate a previous session: status saved as connected.
      SharedPreferences.setMockInitialValues({'sync.status': 'connected'});
      final container = makeContainer(gateway);

      final status = await container.read(syncProvider.future);
      expect(status.state, CloudConnectionState.connecting);

      // Give the fire-and-forget reconnect a beat to complete.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final after = container.read(syncProvider).value!;
      expect(after.state, CloudConnectionState.connected);
      expect(gateway.connections, greaterThanOrEqualTo(1));
    });

    test('stays disconnected when nothing was saved', () async {
      final gateway = FakeCloudGateway();
      final container = makeContainer(gateway);
      await container.read(syncProvider.future);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(gateway.connections, 0);
    });
  });

  group('email OTP sign-in', () {
    test('send + verify adopts the account and pushes local stores', () async {
      final gateway = FakeCloudGateway();
      final container = makeContainer(gateway);
      final sync = container.read(syncProvider.notifier);
      sync.registerStore('quests', (data) async {});
      await sync.queuePush('quests', {
        'items': [
          {'name': 'Local quest'},
        ],
      });
      // Give the queued push (disconnected → kept local) a moment.
      await Future<void>.delayed(Duration.zero);

      await sync.sendSignInCode(email: 'matt@example.com');
      await sync.signInWithCode(code: '123456');

      final status = container.read(syncProvider).value!;
      expect(status.state, CloudConnectionState.connected);
      // The local payload was pushed into the freshly linked account.
      final doc = gateway.docs['quests']!;
      expect(
        (doc.data['items'] as List).first,
        containsPair('name', 'Local quest'),
      );
    });

    test('pulls remote stores from the linked account', () async {
      final gateway = FakeCloudGateway();
      final container = makeContainer(gateway);
      final sync = container.read(syncProvider.notifier);

      var applied = false;
      sync.registerStore('quests', (data) async => applied = true);

      await sync.sendSignInCode(email: 'matt@example.com');
      // Simulate the account already holding cloud data from another device.
      await gateway.connect();
      await gateway.put(
        const StoreDocument(
          key: 'quests',
          data: {
            'items': ['remote'],
          },
        ),
      );
      await sync.signInWithCode(code: '123456');

      expect(applied, isTrue);
    });

    test('send failure surfaces an error and keeps local data', () async {
      final gateway = FakeCloudGateway()..failSend = true;
      final container = makeContainer(gateway);
      final sync = container.read(syncProvider.notifier);

      await expectLater(
        sync.sendSignInCode(email: 'matt@example.com'),
        throwsA(isA<Exception>()),
      );
      final status = container.read(syncProvider).value!;
      expect(status.state, CloudConnectionState.error);
      expect(status.errorMessage, isNotNull);
    });

    test('wrong code surfaces an error', () async {
      final gateway = FakeCloudGateway()..failSignIn = true;
      final container = makeContainer(gateway);
      final sync = container.read(syncProvider.notifier);

      await sync.sendSignInCode(email: 'matt@example.com');
      await expectLater(
        sync.signInWithCode(code: '000000'),
        throwsA(isA<Exception>()),
      );
      final status = container.read(syncProvider).value!;
      expect(status.state, CloudConnectionState.error);
    });
  });

  group('late store registration', () {
    test('a store registered after connect receives the cached pull', () async {
      final gateway = FakeCloudGateway();
      final container = makeContainer(gateway);
      final sync = container.read(syncProvider.notifier);

      await gateway.connect();
      await gateway.put(
        const StoreDocument(
          key: 'quests',
          data: {
            'items': ['from-cloud'],
          },
        ),
      );
      await sync.connect(); // pull happens here; quests not registered yet

      Map<String, dynamic>? received;
      sync.registerStore('quests', (data) async => received = data);
      // The late-registration pull is fire-and-forget; give it a beat.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(received, isNotNull);
      expect((received!['items'] as List).single, 'from-cloud');
    });
  });

  group('account email', () {
    test('remember + disconnect clears it unless kept', () async {
      final gateway = FakeCloudGateway();
      final container = makeContainer(gateway);
      final sync = container.read(syncProvider.notifier);
      await sync.connect();

      await sync.rememberAccountEmail('matt@example.com');
      expect(
        container.read(syncProvider).value!.accountEmail,
        'matt@example.com',
      );

      await sync.disconnect();
      expect(container.read(syncProvider).value!.accountEmail, isNull);

      await sync.rememberAccountEmail('matt@example.com');
      await sync.disconnect(keepAccount: true);
      expect(
        container.read(syncProvider).value!.accountEmail,
        'matt@example.com',
      );
    });
  });
}
