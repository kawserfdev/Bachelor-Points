# Flutter Web Startup Performance Analysis — `lib/main.dart`

> Scope: initial loading experience and the time it takes to navigate from the
> Landing/Splash page to **Login** or **Dashboard**.
> Constraint: **no functional changes** — only startup/first-navigation perf.

---

## 0. Executive Summary

Your app blocks the first frame on a **long sequential `await` chain** inside
[`main()`](lib/main.dart:24) before [`runApp()`](lib/main.dart:67) is ever called.
On Flutter Web this means the user stares at a blank screen while the JS bundle
parses *and* while the following run synchronously, one after another:

```
dotenv.load  →  GetStorage.init  →  Firebase.initializeApp  →
FirebaseAppCheck.activate (reCAPTCHA network call)  →  initServices()
   ├─ StorageService.init()
   ├─ AuthService.init()        (opens an authStateChanges listener)
   └─ RealtimeService.init()    (a no-op that still awaits)
```

Only after **all** of that does [`runApp()`](lib/main.dart:67) fire and the first
frame begin. Then [`_MyAppState.initState()`](lib/main.dart:114) immediately runs
[`NotificationService.init()`](lib/core/notifications/notification_service.dart:33)
on the UI thread (timezone DB load, FCM permission request, token sync…).

The **second** delay the user feels — the “several seconds after clicking
Login/GetStarted” — is caused by the GoRouter redirect guard in
[`buildGoRouter()`](lib/core/routes/go_router_config.dart:164): after sign-in it
**returns `null` (stay on current page)** while
[`hasProfileProvider`](lib/core/providers/auth_providers.dart:61) is still
loading its Firestore `profiles/{uid}` snapshot. The user sits on the Login form
with no feedback until that doc read resolves, *then* the router jumps to
`/home` or `/create-profile`.

The fixes below target both delays. None of them change app behavior.

---

## 1. Startup Flow Trace (what actually runs before the first frame)

| # | Location | Operation | Blocking? | Cost on Web |
|---|----------|-----------|-----------|-------------|
| 1 | [`main.dart:25`](lib/main.dart:25) | `WidgetsFlutterBinding.ensureInitialized()` | yes (required) | low |
| 2 | [`main.dart:31`](lib/main.dart:31) | `await dotenv.load(".env")` | **yes** | HTTP fetch of asset |
| 3 | [`main.dart:34`](lib/main.dart:34) | `await GetStorage.init()` | **yes** | localStorage init |
| 4 | [`main.dart:38`](lib/main.dart:38) | `await Firebase.initializeApp()` | **yes** | network/async, heavy |
| 5 | [`main.dart:47`](lib/main.dart:47) | `await FirebaseAppCheck.activate(ReCaptchaV3Provider)` | **yes — heaviest** | reCAPTCHA network round-trip |
| 6 | [`main.dart:64`](lib/main.dart:64) | `await initServices()` (3 sequential awaits) | **yes** | mostly no-ops + 1 listener |
| 7 | [`main.dart:67`](lib/main.dart:67) | `runApp(...)` | — | first frame finally begins |
| 8 | [`main.dart:117`](lib/main.dart:117) | `NotificationService.init()` in `initState` | **yes (UI thread)** | tz DB + FCM + token sync |
| 9 | [`main.dart:123`](lib/main.dart:123) | `ref.watch(goRouterProvider)` rebuilds whole router | per-change | rebuilds MaterialApp |
| 10 | [`go_router_config.dart:182`](lib/core/routes/go_router_config.dart:182) | redirect returns `null` while profile loads | per-nav | Firestore doc read delay |

---

## 2. Issues Found

### 🔴 Issue 1 — Sequential blocking `await` chain in `main()` before `runApp()`

**Problem**
[`main()`](lib/main.dart:24) awaits six independent-ish operations **one after
another**. Nothing renders until all six finish.

```dart
// lib/main.dart (current)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await dotenv.load(fileName: ".env");        // 1
  await GetStorage.init();                    // 2
  await Firebase.initializeApp(...);          // 3
  await FirebaseAppCheck.instance.activate(...); // 4  ← reCAPTCHA network call
  await initServices();                      // 5..6
  runApp(const ProviderScope(child: MyApp())); // only now does a frame draw
}
```

**Why it affects performance**
On Flutter Web the user sees a **blank white page** for the entire duration of
steps 1–6. `FirebaseAppCheck.activate` with `ReCaptchaV3Provider` performs a
network round-trip to Google; on a cold connection this alone is commonly
**1–3 s**. Because everything is sequential, these costs **add up** instead of
overlapping.

**Recommended solution**
1. Call `runApp()` **immediately** with a lightweight splash shell so the user
   sees your branded loader on the very first frame.
2. Run the boot sequence **after** the first frame (post-frame) and in
   **parallel** where there are no dependencies.
3. Only `dotenv`, `GetStorage`, and `Firebase.initializeApp` are needed before
   the app can meaningfully run. `AppCheck` and `initServices` can be deferred.

**Optimized code example**

```dart
// lib/main.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Show a branded splash on the FIRST frame — no awaiting before runApp.
  runApp(
    const ProviderScope(child: BootShell()),
  );
}

/// Lightweight splash shown instantly while heavy init runs in the background.
class BootShell extends StatefulWidget {
  const BootShell({super.key});
  @override
  State<BootShell> createState() => _BootShellState();
}

class _BootShellState extends State<BootShell> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Parallelize independent work.
    await Future.wait([
      dotenv.load(fileName: ".env"),
      GetStorage.init(),
    ]);

    // Firebase is a dependency for everything else — keep it first.
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint("Firebase init failed: $e");
    }

    // Defer App Check + services to AFTER Firebase, but do NOT block the
    // first navigation on them (see Issue 2 & 3).
    await initServices();

    // App Check can run in the background — it is not needed for the
    // landing/login screens.
    _activateAppCheck(); // fire-and-forget (see Issue 2)

    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return const MyApp();
  }
}
```

> Note: `ProviderScope` must wrap `MyApp` (it already does). Keep the
> `ProviderScope` at the top of `runApp` as shown so Riverpod is available
> during boot.

---

### 🔴 Issue 2 — `FirebaseAppCheck.activate()` with `ReCaptchaV3Provider` blocks startup

**Problem**
[`main.dart:47`](lib/main.dart:47) `await`s App Check activation. On Web the
`ReCaptchaV3Provider` performs a **network call to Google’s reCAPTCHA endpoint**
and exchanges a token. This is one of the single most expensive startup ops and
it is **not required** to show the landing page or to sign in.

**Why it affects performance**
App Check only protects **backend calls** (Firestore/RTDB/Functions enforcement).
The landing page and the login form make no protected calls, so blocking the
first frame on App Check is pure latency waste — typically **1–3 s** on web.

**Recommended solution**
- Activate App Check **lazily / in the background** after Firebase is ready,
  not on the critical path.
- Optionally only activate once the user is authenticated (protected calls
  happen post-auth).

**Optimized code example**

```dart
// Fire-and-forget after Firebase.initializeApp() succeeds.
void _activateAppCheck() {
  // Runs concurrently; does not block runApp or first navigation.
  FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
    webProvider: ReCaptchaV3Provider(
      '6Lf-TiQrAAAAAMjFh0k6sDgMZ7dYPZ0gUvo0GVmI',
    ),
  ).then((_) {
    debugPrint('Firebase App Check activated');
  }).catchError((e) {
    debugPrint("Firebase App Check init failed: $e");
  });
}
```

If you want enforcement before the first *protected* call, you can instead
`await` it lazily inside an auth-gated interceptor — but for the landing/login
flow, background activation is correct.

---

### 🔴 Issue 3 — `NotificationService.init()` runs synchronously in `initState` on the UI thread

**Problem**
[`_MyAppState.initState()`](lib/main.dart:114) calls
[`ref.read(notificationServiceProvider).init()`](lib/core/notifications/notification_service.dart:33)
which does, synchronously/awaited on the UI thread:

- [`tz.initializeTimeZones()`](lib/core/notifications/notification_service.dart:37) — loads the full tz database
- local-notifications platform channel init
- `_fcm.requestPermission(...)` (can prompt the user)
- `_fcm.onTokenRefresh.listen(...)`
- `FirebaseMessaging.onMessage.listen(...)`
- `FirebaseMessaging.onMessageOpenedApp.listen(...)`
- `await _fcm.getInitialMessage()` (async, network)
- `await _fcm.getToken()` + `await _syncToken(token)` (network + device info)

**Why it affects performance**
All of this runs **during the first frame’s `initState`**, jank-blocking the
first paint and the first navigation. On Web, `flutter_local_notifications` and
the tz database are **largely irrelevant** (browsers don’t show local
notifications the same way), yet they still load and initialize.

**Recommended solution**
1. Defer the whole call to `addPostFrameCallback` so it runs **after** the first
   frame paints.
2. Short-circuit platform-specific work on Web (`kIsWeb`) — skip tz DB load and
   local-notifications channel creation on web; keep only FCM.
3. Don’t `await` token sync on the critical path — let it run in the background.

**Optimized code example**

```dart
// lib/main.dart — _MyAppState
@override
void initState() {
  super.initState();
  // Defer heavy notification setup until AFTER the first frame.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(notificationServiceProvider).init();
  });
}
```

```dart
// lib/core/notifications/notification_service.dart — guard web work
Future<void> init() async {
  debugPrint('Initializing NotificationService...');

  // tz DB + local notification channel are not useful on web.
  if (!kIsWeb) {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'bachelorpoints_channel',
        'BachelorPoints Notifications',
        description: 'Channel for high-importance bachelorpoints notifications',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // FCM is relevant on every platform.
  await _fcm.requestPermission(alert: true, badge: true, sound: true);
  _fcm.onTokenRefresh.listen(_syncToken);
  FirebaseMessaging.onMessage.listen(_onForegroundMessageReceived);
  FirebaseMessaging.onMessageOpenedApp.listen(_onPushNotificationTapped);

  final initialMessage = await _fcm.getInitialMessage();
  if (initialMessage != null) _handleDeepLink(initialMessage);

  // Token sync is NOT critical-path — run it in the background.
  if (_ref.read(authStateProvider) == AuthState.authenticated) {
    _fcm.getToken().then((token) {
      if (token != null) _syncToken(token); // fire-and-forget
    });
  }
}
```

---

### 🔴 Issue 4 — GoRouter redirect blocks first navigation on `hasProfileProvider` loading (the “several seconds after Login” delay)

**Problem**
This is the **primary cause of the delay you described**. In
[`buildGoRouter()`](lib/core/routes/go_router_config.dart:164) the redirect
does, for an authenticated user on a public/splash route:

```dart
if (hasProfileAsync.isLoading) return null; // ← stay on current page
final hasProfile = hasProfileAsync.asData?.value;
if (hasProfile == null) return null;
return hasProfile ? GoRoutes.home : GoRoutes.createProfile;
```

`return null` means “stay where you are”. So after the user taps **Login** and
sign-in succeeds, the router **keeps them on the Login page** (form still
visible, no spinner) until the Firestore `profiles/{uid}` snapshot resolves.
Only then does it jump to `/home` or `/create-profile`.

**Why it affects performance**
[`hasProfileProvider`](lib/core/providers/auth_providers.dart:61) is a
`StreamProvider.autoDispose` over `profiles/{uid}.snapshots()`. The first
emission requires a Firestore round-trip. Combined with
[`authUserStreamProvider`](lib/core/providers/auth_providers.dart:13) using
`idTokenChanges()` (which itself needs a network call on web to refresh the
token), the user can wait **2–5 s** on the login form with zero feedback.

**Recommended solution**
1. **Never silently stay on the login form.** When auth becomes
   `authenticated` but the profile check is pending, route to a dedicated
   **loading route** (or show an overlay) so the user sees immediate feedback.
2. Prefer a **one-shot `FutureProvider`** for the initial profile existence
   check instead of a snapshot stream — a `StreamProvider` always starts in
   `isLoading` even for a cached doc, which is what creates the “stay” gap.
3. Make the redirect deterministic: authenticated → always leave the auth
   pages immediately.

**Optimized code example**

```dart
// lib/core/providers/auth_providers.dart
// One-shot profile check — resolves as soon as the doc read completes,
// and does NOT start in a perpetual "loading" state like a snapshot stream.
final hasProfileProvider = FutureProvider.autoDispose<bool>((ref) async {
  final userAsync = ref.watch(authUserStreamProvider);
  final user = userAsync.asData?.value;
  if (user == null) return false;
  final doc =
      await FirebaseFirestore.instance.collection('profiles').doc(user.uid).get();
  return doc.exists;
});
```

```dart
// lib/core/routes/go_router_config.dart — redirect
redirect: (context, state) {
  final location = state.matchedLocation;
  final authState = ref.watch(authStateProvider);
  final hasProfileAsync = ref.watch(hasProfileProvider);
  final authUserAsync = ref.watch(authUserStreamProvider);

  // While the auth stream itself is resolving on cold start, stay put.
  if (authUserAsync.isLoading && location == GoRoutes.splash) return null;

  final isPublicAuth = location == GoRoutes.login ||
      location == GoRoutes.signup ||
      location == GoRoutes.forgotPassword;
  final isVerifyEmail = location == GoRoutes.verifyEmail;
  final isCreateProfile = location == GoRoutes.createProfile;
  final isProtectedApp = _protectedAppRoutes.any(
      (r) => location == r || location.startsWith('$r/'));

  if (authState == AuthState.unauthenticated) {
    return isPublicAuth ? null : GoRoutes.login;
  }
  if (authState == AuthState.emailNotVerified) {
    return (isVerifyEmail || isPublicAuth) ? null : GoRoutes.verifyEmail;
  }

  // Authenticated from here.
  final hasProfile = hasProfileAsync.valueOrNull;

  // On any auth/verify page → leave immediately.
  if (isPublicAuth || isVerifyEmail) {
    if (hasProfile == null) return GoRoutes.authLoading; // show a spinner route
    return hasProfile ? GoRoutes.home : GoRoutes.createProfile;
  }

  if (location == GoRoutes.splash) {
    if (hasProfile == null) return GoRoutes.authLoading;
    return hasProfile ? GoRoutes.home : GoRoutes.createProfile;
  }

  if (isCreateProfile && hasProfile == true) return GoRoutes.home;
  if (isProtectedApp && hasProfile == false) return GoRoutes.createProfile;

  if (location == GoRoutes.toletHome) return GoRoutes.propertySearch;
  return null;
},
```

```dart
// Add a tiny loading route so the user sees feedback, not a frozen login form.
GoRoute(
  path: GoRoutes.authLoading, // '/auth-loading'
  builder: (context, state) => const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  ),
),
```

This single change removes the perceived “frozen login” delay: the user is
moved off the login form **instantly** after sign-in.

---

### 🟠 Issue 5 — `goRouterProvider` rebuilds the entire `GoRouter` on every auth/profile change

**Problem**
[`goRouterProvider`](lib/main.dart:143) is a `Provider` whose body calls
`ref.watch(authStateProvider)`, `ref.watch(hasProfileProvider)`, and
`ref.watch(authUserStreamProvider)` via [`buildGoRouter(ref)`](lib/core/routes/go_router_config.dart:164).
Every time any of those change, Riverpod **rebuilds the provider**, producing a
**brand-new `GoRouter` instance**. [`MyApp.build`](lib/main.dart:121) then
`ref.watch(goRouterProvider)`, so `MaterialApp.router` is rebuilt with a new
`routerConfig`, which can reset internal router state and trigger extra work.

**Why it affects performance**
Constructing a `GoRouter` re-runs the `redirect` closure setup and re-evaluates
the route table. Doing this on every auth/profile emission (and there are
several during sign-in: `idTokenChanges` → profile snapshot) causes repeated
rebuilds right when the user is navigating.

**Recommended solution**
Build the `GoRouter` **once** and tell it to refresh when auth changes using
`refreshListenable`. This is the official Riverpod + GoRouter pattern.

**Optimized code example**

```dart
// lib/main.dart
final goRouterProvider = Provider<GoRouter>((ref) {
  // Listen without rebuilding the provider; just nudge the router.
  final refreshNotifier = ChangeNotifier();
  ref.onDispose(refreshNotifier.dispose);

  ref.listen(authStateProvider, (_, __) => refreshNotifier.notifyListeners());
  ref.listen(hasProfileProvider, (_, __) => refreshNotifier.notifyListeners());

  return buildGoRouter(ref, refreshListenable: refreshNotifier);
});
```

```dart
// lib/core/routes/go_router_config.dart
GoRouter buildGoRouter(Ref ref, {required Listenable refreshListenable}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: GoRoutes.splash,
    refreshListenable: refreshListenable, // ← re-runs redirect without rebuilding router
    redirect: (context, state) {
      // Read providers synchronously inside the redirect (no rebuild of provider).
      final authState = ref.read(authStateProvider);
      final hasProfileAsync = ref.read(hasProfileProvider);
      final authUserAsync = ref.read(authUserStreamProvider);
      // ... same logic as Issue 4 ...
    },
    routes: [/* unchanged */],
  );
}
```

---

### 🟠 Issue 6 — All feature views are eagerly imported into the main bundle (no deferred loading)

**Problem**
[`go_router_config.dart`](lib/core/routes/go_router_config.dart:1) has ~60
top-level `import` statements pulling in **every** feature view and binding
(Tolet, Reports, Chat, Shopping, Meal, Expense, Balance, Profile, …). On
Flutter Web this forces the compiler to put **all** feature code into the
single main JS chunk, so the browser must download and parse the entire app
before the first frame — even though the user only needs the Landing/Login
code to start.

**Why it affects performance**
Flutter Web’s default build is one large `main.dart.js`. Importing every
module up front makes that bundle large and slow to parse. This is the **#1
Flutter Web startup optimization** available: split feature code into
**deferred (lazy) chunks** that load only when first navigated to.

**Recommended solution**
Use Dart’s **deferred imports** for feature modules. Each `import ... deferred
as ...` produces a separate JS chunk fetched on first navigation.

**Optimized code example**

```dart
// lib/core/routes/go_router_config.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../wrapper.dart';
import '../providers/auth_providers.dart';
import '../auth/auth_gate.dart';

// Auth is needed immediately — normal import.
import '../../modules/auth/login/login_view.dart';
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/signup/signup_view.dart';
import '../../modules/auth/signup/signup_binding.dart';
import '../../modules/auth/forgot_password/forgot_password_view.dart';
import '../../modules/auth/forgot_password/forgot_password_binding.dart';
import '../../modules/auth/verify_email/verify_email_view.dart';
import '../../modules/home/home_view.dart';
import '../../modules/home/home_binding.dart';

// Everything else is deferred into separate JS chunks.
import '../../modules/tolet/views/property_search_view.dart' deferred as tolet_search;
import '../../modules/tolet/views/tolet_view.dart' deferred as tolet_home;
import '../../modules/tolet/bindings/tolet_binding.dart' deferred as tolet_binding;
// ... etc for each feature module ...

class _LazyBuilder {
  static Future<void> _load(Iterable<Future<void>> loads) => Future.wait(loads);
}

// In the routes list:
GoRoute(
  path: GoRoutes.propertySearch,
  builder: (context, state) {
    return FutureBuilder(
      future: _LazyBuilder._load([
        tolet_search.loadLibrary(),
        tolet_binding.loadLibrary(),
      ]),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        tolet_binding.ToletBinding().dependencies();
        return tolet_search.PropertySearchView();
      },
    );
  },
),
```

> This is a larger refactor; you can apply it **incrementally**, starting with
> the heaviest feature modules (Tolet, Reports, Chat). Even splitting just
> those noticeably shrinks the initial JS chunk.

---

### 🟠 Issue 7 — `RealtimeService` is eagerly initialized but is a no-op at startup

**Problem**
[`initServices()`](lib/main.dart:70) constructs and `await`s
[`RealtimeService.init()`](lib/services/realtime_service.dart:8), which does
**nothing** (`return this`). It is registered `permanent: true` and kept alive
forever, but it is only used for meal/expense/deposit/member streams — i.e.
**only after** the user is inside a mess.

**Why it affects performance**
It adds an unnecessary object allocation, an `await` hop, and a permanent
service to the startup path for zero benefit at landing/login time.

**Recommended solution**
Register `RealtimeService` **lazily** (only when a feature that needs it first
runs), or simply remove it from `initServices()` and let the relevant feature
binding create it on demand.

**Optimized code example**

```dart
// lib/main.dart — initServices()
Future<void> initServices() async {
  // Storage + Auth are needed early (theme/locale/login depend on them).
  final storageService = StorageService();
  Get.put<StorageService>(storageService, permanent: true);
  try {
    await storageService.init();
  } catch (e) {
    debugPrint("StorageService init failed: $e");
  }

  final authService = AuthService();
  Get.put<AuthService>(authService, permanent: true);
  try {
    await authService.init();
  } catch (e) {
    debugPrint("AuthService init failed: $e");
  }

  // RealtimeService is NOT needed at startup — register lazily.
  Get.lazyPut<RealtimeService>(() => RealtimeService(), fenix: true);
}
```

> `RealtimeService.init()` is a no-op, so lazy registration is safe. If you
> later add real init work there, trigger it from the first feature that uses
> it (e.g. `MealBinding`).

---

### 🟠 Issue 8 — Duplicate auth services do double work (GetX `AuthService` + Riverpod `AppAuthService`)

**Problem**
You have two auth services:
- [`services/auth_service.dart`](lib/services/auth_service.dart:11) — GetX `AuthService`, used by `LoginController`.
- [`core/auth/auth_service.dart`](lib/core/auth/auth_service.dart:10) — `AppAuthService`, used by Riverpod providers and the router.

[`AuthService.init()`](lib/services/auth_service.dart:17) opens an
`authStateChanges().listen(...)` listener, and
[`authUserStreamProvider`](lib/core/providers/auth_providers.dart:13) opens
`idTokenChanges()`. So **two** Firebase auth listeners run in parallel, doing
redundant work and risking double-triggered side effects during migration.

**Why it affects performance**
Two listeners, two stream subscriptions, double the auth-state churn and
rebuilds — right on the critical navigation path.

**Recommended solution**
Until migration completes, keep **one** source of truth. The router already
uses `AppAuthService` via Riverpod. Have the GetX `AuthService` delegate to the
same `FirebaseAuth.instance` stream **without** opening its own listener, or
remove its listener entirely (the `currentUser` Rx is only read by legacy
controllers and can be populated from `FirebaseAuth.instance.currentUser`
lazily).

**Optimized code example**

```dart
// lib/services/auth_service.dart — drop the redundant listener
class AuthService extends GetxService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  final Rx<User?> currentUser = Rx<User?>(null);

  Future<AuthService> init() async {
    // Populate synchronously from the cached user — no extra listener.
    // The router already listens via AppAuthService.authStateChanges.
    currentUser.value = _auth.currentUser;
    return this;
  }
  // ... rest unchanged ...
}
```

---

### 🟡 Issue 9 — Excessive `debugPrint` calls in hot paths (router redirect, validators, storage)

**Problem**
The router redirect in [`go_router_config.dart:175-263`](lib/core/routes/go_router_config.dart:175)
emits ~10 `debugPrint` calls **with string interpolation** on **every
navigation**. [`StorageService`](lib/services/storage_service.dart:14) logs on
every read/write, and [`LoginController.validateEmail`](lib/modules/auth/login/login_controller.dart:30)
logs on every keystroke.

**Why it affects performance**
`debugPrint` is **not** stripped in release mode (only `assert` is). The
string interpolation (`'… $location …'`) runs regardless, and on web each call
routes through the console. During sign-in you get several redirect passes ×
~10 prints = dozens of string allocations on the navigation hot path.

**Recommended solution**
Gate logging behind `kDebugMode`, or use a leveled logger (you already depend
on `logger`). At minimum, remove the per-keystroke and per-navigation prints.

**Optimized code example**

```dart
// lib/core/routes/go_router_config.dart
redirect: (context, state) {
  final location = state.matchedLocation;
  if (kDebugMode) {
    debugPrint('[Router] location=$location auth=${ref.read(authStateProvider)}');
  }
  // ... logic ...
},
```

```dart
// lib/services/storage_service.dart
T? readData<T>(String key) => _box.read<T>(key); // no per-call logging
```

```dart
// lib/modules/auth/login/login_controller.dart
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  if (!GetUtils.isEmail(value)) return 'Please enter a valid email';
  return null; // no per-keystroke debugPrint
}
```

---

### 🟡 Issue 10 — `AppWrapper` instantiates `MessController` inside `build()` (desktop path)

**Problem**
[`wrapper.dart:71`](lib/wrapper.dart:71), on desktop, runs inside `build()`:

```dart
final messController = Get.isRegistered<MessController>()
    ? Get.find<MessController>()
    : Get.put(MessController());
```

`build()` runs on every rebuild. `MessController` (a GetX controller) typically
starts Firestore queries in `onInit`. Doing this from `build` couples data
fetch to the widget tree and can trigger heavy work during the first
navigation to a desktop shell.

**Why it affects performance**
Controller construction + Firestore reads happen on the UI thread during
layout, and can repeat if the widget rebuilds before registration completes.

**Recommended solution**
Move controller registration into a **binding** invoked by the route, not
into `build()`. Read it via `Get.find` (or `Get.put` guarded by a flag set once).

**Optimized code example**

```dart
// lib/modules/home/home_binding.dart (or a dedicated shell binding)
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    if (!Get.isRegistered<MessController>()) {
      Get.put<MessController>(MessController(), permanent: true);
    }
  }
}

// lib/wrapper.dart — just read, never create in build
final messController = Get.find<MessController>();
```

---

### 🟡 Issue 11 — No HTML splash in `web/index.html` (blank screen before Flutter paints)

**Problem**
[`web/index.html`](web/index.html:36) only contains
`<script src="flutter_bootstrap.js" async></script>`. Until Flutter’s JS loads,
parses, and `main()` finishes its await chain, the user sees a **blank white
page**.

**Why it affects performance**
Even after you optimize `main()`, there is still a window between the browser
loading the page and Flutter painting the first frame. An HTML splash fills
that gap instantly and is the cheapest perceived-perf win on web.

**Recommended solution**
Add a lightweight inline splash + use the `onEntrypointLoaded` hook to remove
it once Flutter is ready.

**Optimized code example**

```html
<!-- web/index.html -->
<style>
  #flutter-splash {
    position: fixed; inset: 0;
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    background: #ffffff; color: #1f6f4f;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    z-index: 9999;
    transition: opacity .4s ease;
  }
  #flutter-splash .logo { font-size: 28px; font-weight: 800; }
  #flutter-splash .spinner {
    margin-top: 18px; width: 28px; height: 28px;
    border: 3px solid #e3e3e3; border-top-color: #1f6f4f;
    border-radius: 50%; animation: spin 1s linear infinite;
  }
  @keyframes spin { to { transform: rotate(360deg); } }
</style>
<body>
  <div id="flutter-splash">
    <div class="logo">BachelorPoints</div>
    <div class="spinner"></div>
  </div>
  <script src="flutter_bootstrap.js" async></script>
  <script>
    _flutter.buildConfig = { /* optional */ };
    window.addEventListener('flutter-first-frame', function () {
      var s = document.getElementById('flutter-splash');
      if (s) { s.style.opacity = '0'; setTimeout(() => s.remove(), 400); }
    });
  </script>
</body>
```

---

### 🟡 Issue 12 — `dotenv.load()` blocks startup but most config already lives in `firebase_options.dart`

**Problem**
[`main.dart:31`](lib/main.dart:31) `await dotenv.load(".env")` fetches the
`.env` asset before `runApp`. But Firebase config is already compiled into
[`firebase_options.dart`](lib/firebase_options.dart), so `.env` is likely only
needed for a few runtime values (e.g. a reCAPTCHA site key, API base URL).

**Why it affects performance**
It’s an extra awaited asset fetch on the critical path. If nothing on the
landing/login screen reads `dotenv`, it doesn’t need to block `runApp`.

**Recommended solution**
Load `.env` **lazily** — only when a value is first read — or load it in the
background after the first frame. Provide a synchronous fallback for any value
needed before load completes.

**Optimized code example**

```dart
// Background-load after first frame; callers await a completer.
final _dotenvReady = Completer<void>();
Future<void> ensureDotenv() async {
  if (_dotenvReady.isCompleted) return;
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}
  _dotenvReady.complete();
}

// In BootShell._boot(): kick it off in parallel, don't block runApp on it.
Future.wait([GetStorage.init(), ensureDotenv(), Firebase.initializeApp(...)]);
```

---

## 3. Prioritized Improvement List

| Priority | Issue | Fix | Est. startup / first-nav saving |
|----------|-------|-----|----------------------------------|
| 🔴 High | #1 Sequential `await` chain in `main()` | `runApp` first, boot post-frame, parallelize | **400–900 ms** (overlap + earlier first paint) |
| 🔴 High | #2 `AppCheck.activate` (reCAPTCHA) on critical path | Background/lazy activation | **1–3 s** on web (network round-trip removed from critical path) |
| 🔴 High | #4 Redirect stays on Login while profile loads | Route to a loading route immediately | **removes the “frozen login” delay** (perceived 2–5 s → instant feedback) |
| 🔴 High | #3 `NotificationService.init()` in `initState` | Defer to post-frame + guard web | **150–400 ms** first-frame jank |
| 🟠 Medium | #6 All views eagerly imported (one big JS chunk) | Deferred imports per feature | **500–2000 ms** initial JS parse on slow devices (largest single win for cold load) |
| 🟠 Medium | #5 `goRouterProvider` rebuilds whole router | `refreshListenable`, build once | **50–150 ms** per auth/profile change + fewer rebuilds |
| 🟠 Medium | #7 `RealtimeService` eagerly init (no-op) | Lazy registration | **10–30 ms** + smaller permanent footprint |
| 🟠 Medium | #8 Duplicate auth services / double listener | Single source of truth | **reduces auth churn / rebuilds** during sign-in |
| 🟡 Low | #9 Excessive `debugPrint` in hot paths | `kDebugMode` gate / logger | **10–50 ms** + cleaner release builds |
| 🟡 Low | #10 `MessController` created in `build()` | Move to binding | avoids repeated construction on rebuilds |
| 🟡 Low | #11 No HTML splash in `index.html` | Inline splash + first-frame hook | **perceived** 200–800 ms covered (blank → branded) |
| 🟡 Low | #12 `dotenv.load` blocks startup | Lazy/background load | **50–150 ms** asset fetch off critical path |

**Cumulative estimate (Issues #1–#5 + #11):** cold start to first paint
typically drops from **~3–6 s** to **~0.8–1.5 s**, and the Login → Dashboard
transition from **2–5 s of frozen UI** to **near-instant** (with a brief
loading route while the profile doc resolves).

---

## 4. Best Practices for a Smooth First Navigation on Flutter Web

1. **`runApp` first, init second.** Show a branded splash on the very first
   frame; do heavy init in `initState`/post-frame or a boot widget. Never block
   `runApp` on network calls that the first screen doesn’t need.
2. **Parallelize independent awaits** with `Future.wait`. Sequential `await`
   on independent work is a common, silent tax.
3. **Defer everything not needed for the first screen.** App Check, FCM,
   local notifications, realtime streams, and feature controllers can all
   initialize after the first frame or lazily on first use.
4. **Use deferred (lazy) imports** for feature modules so the initial JS chunk
   contains only Landing/Login code. This is the highest-leverage web
   optimization available to you.
5. **Never freeze the user on a form during async routing.** If a redirect
   depends on an async value (profile check), route to a loading screen —
   don’t `return null` and leave them staring at the login form.
6. **Prefer one-shot `FutureProvider` over `StreamProvider` for one-time
   decisions** (like “does a profile exist?”). Streams always start in
   `isLoading`, which creates artificial “stay” gaps in redirects.
7. **Build `GoRouter` once; use `refreshListenable`** to re-run the redirect
   without reconstructing the router. Avoid `ref.watch`ing auth providers
   inside a `Provider` that returns the router.
8. **Guard platform-specific code with `kIsWeb` / `Platform`.** Don’t load the
   timezone DB or local-notification channels on web when they aren’t used.
9. **Gate logging behind `kDebugMode`.** `debugPrint` and its string
   interpolation run in release mode; keep them off navigation hot paths.
10. **Add an HTML splash in `index.html`** with a `flutter-first-frame`
    listener. It covers the unavoidable JS-load gap with zero Dart cost.
11. **Single source of truth for auth.** During GetX→Riverpod migration, ensure
    only one auth listener drives navigation; duplicate listeners cause double
    rebuilds and race-y redirects.
12. **Measure with `PerformanceOverlay` + web profiler.** After each change,
    confirm the win with `flutter run --profile --web-renderer auto` and the
    browser Performance tab; don’t optimize blind.

---

### Files touched by the recommended changes (for reference)

- [`lib/main.dart`](lib/main.dart:24) — boot shell, deferred App Check, deferred notifications
- [`lib/core/routes/go_router_config.dart`](lib/core/routes/go_router_config.dart:164) — loading route, `refreshListenable`, deferred imports
- [`lib/core/providers/auth_providers.dart`](lib/core/providers/auth_providers.dart:61) — `FutureProvider` for profile check
- [`lib/core/notifications/notification_service.dart`](lib/core/notifications/notification_service.dart:33) — web guard, background token sync
- [`lib/services/auth_service.dart`](lib/services/auth_service.dart:17) — drop redundant listener
- [`lib/services/realtime_service.dart`](lib/services/realtime_service.dart:8) — lazy registration
- [`lib/wrapper.dart`](lib/wrapper.dart:71) — move `MessController` to a binding
- [`web/index.html`](web/index.html:36) — HTML splash + first-frame hook
