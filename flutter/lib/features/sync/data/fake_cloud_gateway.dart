import '../domain/cloud_gateway.dart';
import '../domain/sync_models.dart';

/// In-memory [CloudGateway] for tests (and for demos without network).
class FakeCloudGateway implements CloudGateway {
  FakeCloudGateway({this.failSaves = false});

  final Map<String, StoreDocument> docs = {};
  int connections = 0;
  int disconnects = 0;

  /// When true, every [put] throws — simulates being offline.
  bool failSaves;

  /// When true, [signInWithCode] throws — simulates a wrong code.
  bool failSignIn = false;

  /// When true, [sendSignInCode] throws — simulates a network failure.
  bool failSend = false;

  /// Email OTP codes already sent and not yet consumed.
  final Map<String, ({String userId, String secret})> _codes = {};
  final Map<String, String> _otpAccounts = {};
  final Map<String, String> _emailsByUserId = {};

  String? _playerId;

  @override
  Future<String> connect() async {
    connections++;
    _playerId ??= 'fake-player-1';
    return _playerId!;
  }

  @override
  Future<bool> hasSession() async => _playerId != null;

  @override
  Future<StoreDocument?> fetch(String key) async {
    if (_playerId == null) {
      throw StateError('fetch before connect');
    }
    return docs[key];
  }

  @override
  Future<void> put(StoreDocument doc) async {
    if (_playerId == null) {
      throw StateError('put before connect');
    }
    if (failSaves) {
      throw Exception('network unavailable');
    }
    docs[doc.key] = doc;
  }

  @override
  Future<void> disconnect() async {
    disconnects++;
    _playerId = null;
  }

  @override
  Future<({String userId, String secret})> sendSignInCode({
    required String email,
  }) async {
    if (failSend) {
      throw Exception('network unavailable');
    }
    final secret = _mkSecret();
    final userId = _otpAccounts.putIfAbsent(
      email,
      () => 'fake-user-${_otpAccounts.length + 1}',
    );
    final handle = (userId: userId, secret: secret);
    _codes[email] = handle;
    _emailsByUserId[userId] = email;
    return handle;
  }

  @override
  Future<void> signInWithCode({
    required ({String userId, String secret}) handle,
    required String code,
  }) async {
    if (failSignIn) {
      failSignIn = false;
      throw Exception('invalid code');
    }
    // Test seam: any code matches the last code sent for the handle's email.
    final email = _emailsByUserId[handle.userId];
    final expected = email == null ? null : _codes[email];
    if (expected == null) {
      throw Exception('no code sent for this email');
    }
    _playerId = 'account:${handle.userId}';
    _codes.remove(email);
  }

  static String _mkSecret() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}
