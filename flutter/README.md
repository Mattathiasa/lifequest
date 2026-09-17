# lifequest

LifeQuest — turn real-life goals into an RPG adventure. Flutter implementation
of the design handoff in the repository root (`README.md`, `CLAUDE.md`).

## Run

```bash
flutter pub get
flutter run                # pick a device or emulator
flutter analyze            # must be clean before every commit
flutter test               # 133 unit + widget tests
```

## Online data (Appwrite Cloud)

The app is offline-first: everything works with no account, and quest/progress
data lives in the cloud once connected.

### One-time backend setup (5 minutes)

1. Create a free project at [cloud.appwrite.io](https://cloud.appwrite.io).
2. Add a platform per target OS — Android package
   `com.mattathias.lifequest`, iOS bundle id from Xcode.
3. **Databases → Add database** with id `lifequest`.
4. Inside it, **Add collection** with id `game_state`, **attributes: none**
   (documents are schemaless JSON), and **Permissions → role `any`** with
   `documents.read`, `documents.create`, `documents.update` enabled.
5. Note the **Project ID** from Settings.

### In the app

- **Profile → Cloud sync** shows connection state, sync-now and disconnect.
- **Connect** creates a private anonymous workspace (endpoint and database id
  are prefilled; paste the project id). Subsequent launches reconnect
  automatically and sync both ways (offline writes flush on reconnect).
- **Carry your adventure** — enter an email, we send a one-time code, enter it
  to link the device to a portable account. Repeat on any other device
  connected to the same project to pull the same data. No passwords anywhere.

No API keys are embedded in the client; the app speaks to Appwrite with the
project id only, authenticated by the per-device session.

## Architecture

Feature-first clean architecture (see `CLAUDE.md`):

```
lib/
  core/          theme tokens, shared widgets, services
  features/
    trail/ quests/ focus/ character/ progress/ profile/
    onboarding/ settings/ progression/ sync/
```

Repositories are local-first (`SharedPreferences`) wrapped by `Synced*`
adapters that mirror writes through `SyncController` behind the
`CloudGateway` interface (`AppwriteCloudGateway` today, Firebase possible
later) without touching a widget.
