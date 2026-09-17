import 'sync_models.dart';

/// Contract a cloud backend must satisfy for LifeQuest sync.
///
/// The contract is deliberately tiny — per-player JSON documents with a
/// compare-and-swap update timestamp — so several backends can implement it.
/// The shipped implementation is Appwrite Cloud (`AppwriteCloudGateway`);
/// tests use `FakeCloudGateway`. Firebase or any other provider can be added
/// later without touching the sync controller or repositories.
abstract interface class CloudGateway {
  /// Create a session for this device and return the stable player id used
  /// as the document namespace.
  Future<String> connect();

  /// True when a usable session already exists on this device.
  Future<bool> hasSession();

  /// Fetch one document by [key]. Returns null when it does not exist yet.
  Future<StoreDocument?> fetch(String key);

  /// Create or overwrite the document at [key] with [data].
  Future<void> put(StoreDocument doc);

  /// Remove any session from this device (cloud data is untouched).
  Future<void> disconnect();

  /// Send a one-time sign-in code to [email]. The device keeps its local
  /// data; linking uploads it to the account the code belongs to. Returns
  /// the userId + secret handle needed by [signInWithCode].
  Future<({String userId, String secret})> sendSignInCode({
    required String email,
  });

  /// Exchange a one-time code for a session. [handle] comes from
  /// [sendSignInCode]; [code] is what the player received by email.
  Future<void> signInWithCode({
    required ({String userId, String secret}) handle,
    required String code,
  });
}
