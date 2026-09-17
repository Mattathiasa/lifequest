/// Default Appwrite Cloud coordinates. The endpoint is regional; the settings
/// sheet prefills it and the user can override all three values.
const defaultEndpoint = 'https://fra.cloud.appwrite.io/v1';
const defaultDatabaseId = 'lifequest';
const defaultCollectionId = 'game_state';

/// Keys of the game stores synced through the gateway.
const questsStoreKey = 'quests';
const gameStateStoreKey = 'game_state';

/// Connection state of the cloud sync feature — rendered by the Profile
/// "Cloud sync" row.
enum CloudConnectionState {
  /// No cloud account connected; everything is local-only.
  disconnected,

  /// Connecting / creating the session and pulling the remote snapshot.
  connecting,

  /// Connected and in sync.
  connected,

  /// Connected but some writes are queued waiting for the network.
  syncing,

  /// The last cloud operation failed (offline, bad project id, …).
  error,
}

/// Where a change currently lives.
enum ChangeLocation { localOnly, syncedToCloud }

/// A document stored by a [CloudGateway]: a stable [key] plus its JSON payload.
/// The payload shape is opaque to the gateway — repositories own it.
class StoreDocument {
  const StoreDocument({required this.key, required this.data});

  /// Stable identifier within the player's cloud workspace, e.g. `quests`.
  final String key;

  /// JSON-encodable payload.
  final Map<String, dynamic> data;
}

/// A pending local write that could not be pushed yet (offline).
class PendingChange {
  const PendingChange({required this.key, required this.queuedAt});

  final String key;
  final DateTime queuedAt;
}

/// What the UI needs to know about sync — one object, derived from the
/// controller, so widgets never poke at internals.
class CloudSyncStatus {
  const CloudSyncStatus({
    this.state = CloudConnectionState.disconnected,
    this.lastSyncedAt,
    this.pendingCount = 0,
    this.errorMessage,
    this.accountEmail,
  });

  final CloudConnectionState state;
  final DateTime? lastSyncedAt;
  final int pendingCount;
  final String? errorMessage;

  /// Email of the linked account (set after an email-OTP sign-in). Display
  /// only — stored locally, never synced.
  final String? accountEmail;

  CloudSyncStatus copyWith({
    CloudConnectionState? state,
    DateTime? lastSyncedAt,
    bool clearLastSynced = false,
    int? pendingCount,
    String? errorMessage,
    bool clearError = false,
    String? accountEmail,
  }) {
    return CloudSyncStatus(
      state: state ?? this.state,
      lastSyncedAt: clearLastSynced
          ? null
          : (lastSyncedAt ?? this.lastSyncedAt),
      pendingCount: pendingCount ?? this.pendingCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      accountEmail: accountEmail ?? this.accountEmail,
    );
  }

  /// Short mono label for the settings row.
  String get label => switch (state) {
    CloudConnectionState.disconnected => 'OFF',
    CloudConnectionState.connecting => 'LINKING…',
    CloudConnectionState.connected => 'ON',
    CloudConnectionState.syncing => 'SYNCING',
    CloudConnectionState.error => 'RETRY',
  };
}
