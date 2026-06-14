# BachelorPoints — Production Implementation Plan

> **Date:** 2026-06-14
> **Prerequisite Reading:** [`docs/ARCHITECTURE_AUDIT.md`](ARCHITECTURE_AUDIT.md)
> **Stack:** Flutter + Firebase (only), with Isar offline DB

---

## Table of Contents

1. [Redesigned Firestore Collection Structure](#1-redesigned-firestore-collection-structure)
2. [Firestore Security Rules](#2-firestore-security-rules)
3. [Authentication Flow (Redesigned)](#3-authentication-flow-redesigned)
4. [Role-Based Access Control Architecture](#4-role-based-access-control-architecture)
5. [Offline-First Sync Strategy](#5-offline-first-sync-strategy)
6. [Production Folder Structure](#6-production-folder-structure)
7. [Flutter Architecture — Layers](#7-flutter-architecture--layers)
8. [Composite Index Strategy](#8-composite-index-strategy)
9. [Query Optimization Strategy](#9-query-optimization-strategy)
10. [Refactoring Roadmap (Phased)](#10-refactoring-roadmap-phased)

---

## 1. Redesigned Firestore Collection Structure

### 1.1 Collection Map

```
users/{uid}
├── email: string
├── phone: string | null
├── auth_providers: string[]        // ["email", "google", "phone"]
├── is_active: bool
├── created_at: Timestamp
├── last_login_at: Timestamp
└── Subcollections:
    ├── fcm_tokens/{token}
    │   ├── token: string
    │   ├── device_name: string
    │   ├── platform: string        // "android" | "ios" | "web"
    │   ├── created_at: Timestamp
    │   └── last_used_at: Timestamp
    ├── auth_logs/{logId}
    │   ├── event: string           // "login" | "logout" | "signup" | "password_reset" | "phone_link"
    │   ├── provider: string        // "email" | "google" | "phone"
    │   ├── ip_address: string
    │   ├── device_info: string
    │   ├── success: bool
    │   ├── failure_reason: string?
    │   └── created_at: Timestamp
    └── memberships/{messId}
        ├── mess_id: string
        ├── mess_name: string       // denormalized for fast list display
        ├── role: string
        ├── joined_at: Timestamp
        └── is_active: bool

user_profiles/{uid}
├── full_name: string
├── phone_number: string | null
├── avatar_url: string | null
├── display_name: string
├── created_at: Timestamp
└── updated_at: Timestamp

messes/{messId}
├── name: string
├── invite_code: string              // UNIQUE, 6-char alphanumeric
├── created_by: string               // uid of creator (Owner)
├── member_count: number             // denormalized counter
├── is_active: bool
├── created_at: Timestamp
├── updated_at: Timestamp
└── Subcollections:
    ├── members/{userId}
    │   ├── user_id: string
    │   ├── role: string             // "owner" | "manager" | "member"
    │   ├── joined_at: Timestamp
    │   ├── invited_by: string
    │   └── is_active: bool
    ├── settings/{configId}
    │   ├── meal_cutoff_time: string  // "22:00"
    │   ├── currency: string          // "BDT"
    │   ├── timezone: string          // "Asia/Dhaka"
    │   └── updated_at: Timestamp
    ├── meals/{mealId}
    │   ├── user_id: string
    │   ├── date: Timestamp
    │   ├── breakfast: number
    │   ├── lunch: number
    │   ├── dinner: number
    │   ├── status: string            // "pending" | "approved" | "rejected"
    │   ├── created_at: Timestamp
    │   └── updated_at: Timestamp
    ├── expenses/{expenseId}
    │   ├── added_by: string
    │   ├── amount: number
    │   ├── category: string          // "bazar" | "utility" | "rent" | "other"
    │   ├── description: string?
    │   ├── date: Timestamp
    │   ├── status: string            // "pending" | "approved" | "rejected"
    │   ├── reviewed_by: string?
    │   ├── created_at: Timestamp
    │   └── updated_at: Timestamp
    ├── deposits/{depositId}
    │   ├── user_id: string
    │   ├── amount: number
    │   ├── date: Timestamp
    │   ├── received_by: string?
    │   ├── status: string            // "pending" | "approved" | "rejected"
    │   ├── created_at: Timestamp
    │   └── updated_at: Timestamp
    ├── bazar_schedules/{scheduleId}
    │   ├── user_id: string
    │   ├── date: Timestamp
    │   ├── status: string
    │   └── created_at: Timestamp
    ├── requests/{requestId}
    │   ├── user_id: string
    │   ├── type: string              // "meal_change" | "leave" | "expense_review"
    │   ├── status: string            // "pending" | "approved" | "rejected"
    │   ├── details: map
    │   ├── reviewed_by: string?
    │   ├── reviewed_at: Timestamp?
    │   └── created_at: Timestamp
    └── messages/{messageId}
        ├── user_id: string
        ├── sender_name: string
        ├── message: string
        ├── type: string              // "text" | "image" | "system"
        └── created_at: Timestamp

notifications/{notificationId}
├── user_id: string
├── mess_id: string?
├── type: string                     // "meal_reminder" | "expense_added" | "member_joined" | "request_update"
├── title: string
├── body: string
├── data: map?
├── is_read: bool
├── read_at: Timestamp?
└── created_at: Timestamp

subscriptions/{subscriptionId}
├── mess_id: string
├── user_id: string
├── plan: string                     // "free" | "pro" | "enterprise"
├── status: string                   // "active" | "cancelled" | "expired"
├── started_at: Timestamp
├── expires_at: Timestamp
├── auto_renew: bool
└── created_at: Timestamp
```

### 1.2 Subcollection Rationale

Using subcollections (instead of flat collections with `mess_id` fields) provides:

| Benefit | Explanation |
|---------|-------------|
| **Security Rules** | Easier to write: `match /messes/{messId}/meals/{mealId}` scopes automatically |
| **Atomic Deletion** | Deleting a mess can cascade-delete all subcollections |
| **Query Isolation** | No risk of cross-mess data leaks from bad queries |
| **Composite Index Scoping** | Indexes are per-collection, reducing namespace pollution |
| **Read Cost** | Queries on subcollections are scoped — no filtering on `mess_id` needed |

### 1.3 Denormalization Strategy

| Data | Denormalized To | Reason |
|------|----------------|--------|
| `mess_name` | `users/{uid}/memberships/{messId}.mess_name` | Avoid extra read on mess list screen |
| `full_name` | `messes/{messId}/messages/{msgId}.sender_name` | Chat messages need sender name; profiles change rarely |
| `member_count` | `messes/{messId}.member_count` | Avoid counting members on dashboard load |
| `avatar_url` | `messes/{messId}/members/{userId}.avatar_url` | Fast member list rendering |

---

## 2. Firestore Security Rules

### 2.1 Complete Rules (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ─────────────────────────────────────────────
    // HELPER FUNCTIONS
    // ─────────────────────────────────────────────

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function getRole(messId) {
      return get(/databases/$(database)/documents/messes/$(messId)/members/$(request.auth.uid)).data.role;
    }

    function isMessMember(messId) {
      return exists(/databases/$(database)/documents/messes/$(messId)/members/$(request.auth.uid));
    }

    function isMessAdmin(messId) {
      let role = getRole(messId);
      return role == 'owner' || role == 'manager';
    }

    function isMessOwner(messId) {
      return getRole(messId) == 'owner';
    }

    function isValidRole(role) {
      return role in ['owner', 'manager', 'member'];
    }

    function isValidInviteCode(code) {
      return code is string && code.size() == 6 && code == code.upper();
    }

    function isValidMealStatus(status) {
      return status in ['pending', 'approved', 'rejected'];
    }

    // ─────────────────────────────────────────────
    // USERS COLLECTION
    // ─────────────────────────────────────────────

    match /users/{uid} {
      // Users can read their own document
      allow read: if isAuthenticated() && isOwner(uid);
      // Users can create their own document on signup
      allow create: if isAuthenticated() && isOwner(uid);
      // Users can update their own document (except auth_providers)
      allow update: if isAuthenticated() && isOwner(uid)
                    && request.resource.data.diff(resource.data).affectedKeys()
                       .hasOnly(['phone', 'last_login_at']);
      // No deletion by clients
      allow delete: if false;

      // FCM Tokens subcollection
      match /fcm_tokens/{token} {
        allow read, write: if isOwner(uid);
      }

      // Auth Logs subcollection
      match /auth_logs/{logId} {
        allow read: if isOwner(uid);
        allow create: if isOwner(uid);
        allow update, delete: if false;
      }

      // Memberships subcollection (denormalized)
      match /memberships/{messId} {
        allow read: if isOwner(uid);
        allow create, update, delete: if false; // managed via messes/{messId}/members
      }
    }

    // ─────────────────────────────────────────────
    // USER PROFILES COLLECTION
    // ─────────────────────────────────────────────

    match /user_profiles/{uid} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && isOwner(uid);
      allow update: if isAuthenticated() && isOwner(uid);
      allow delete: if false;
    }

    // ─────────────────────────────────────────────
    // MESSES COLLECTION
    // ─────────────────────────────────────────────

    match /messes/{messId} {
      // Any authenticated user can read messes (to discover via invite code)
      allow read: if isAuthenticated();
      // Any authenticated user can create a mess
      allow create: if isAuthenticated()
                    && request.resource.data.created_by == request.auth.uid
                    && isValidInviteCode(request.resource.data.invite_code)
                    && request.resource.data.name is string
                    && request.resource.data.name.size() >= 3;
      // Only owner can update mess details
      allow update: if isMessOwner(messId);
      // Only owner can delete mess
      allow delete: if isMessOwner(messId);

      // ── MEMBERS (subcollection) ──
      match /members/{userId} {
        // Mess members can view member list
        allow read: if isMessMember(messId);
        // Owner/Manager can add members; self-join via invite code handled by cloud function
        allow create: if isMessAdmin(messId)
                      && request.resource.data.user_id == userId
                      && isValidRole(request.resource.data.role)
                      && request.resource.data.role != 'owner';
        // Admin can update member roles (cannot demote owner)
        allow update: if isMessAdmin(messId)
                      && resource.data.role != 'owner'
                      && isValidRole(request.resource.data.role);
        // Owner can remove members; members can leave
        allow delete: if isMessOwner(messId) || isOwner(userId);
      }

      // ── SETTINGS ──
      match /settings/{configId} {
        allow read: if isMessMember(messId);
        allow write: if isMessAdmin(messId);
      }

      // ── MEALS ──
      match /meals/{mealId} {
        allow read: if isMessMember(messId);
        // Members can add/update their own meals
        allow create: if isMessMember(messId)
                      && request.resource.data.user_id == request.auth.uid;
        allow update: if (isOwner(request.resource.data.user_id) || isMessAdmin(messId))
                      && request.resource.data.user_id == resource.data.user_id;
        allow delete: if false; // soft-delete via status only
      }

      // ── EXPENSES ──
      match /expenses/{expenseId} {
        allow read: if isMessMember(messId);
        allow create: if isMessMember(messId)
                      && request.resource.data.added_by == request.auth.uid
                      && request.resource.data.amount > 0;
        // Only admin can approve/reject
        allow update: if (isOwner(resource.data.added_by) && resource.data.status == 'pending')
                      || (isMessAdmin(messId)
                          && request.resource.data.diff(resource.data).affectedKeys()
                             .hasOnly(['status', 'reviewed_by', 'updated_at']));
        allow delete: if false;
      }

      // ── DEPOSITS ──
      match /deposits/{depositId} {
        allow read: if isMessMember(messId);
        allow create: if isMessMember(messId)
                      && request.resource.data.user_id == request.auth.uid
                      && request.resource.data.amount > 0;
        allow update: if isMessAdmin(messId)
                      && request.resource.data.diff(resource.data).affectedKeys()
                         .hasOnly(['status', 'updated_at']);
        allow delete: if false;
      }

      // ── BAZAR SCHEDULES ──
      match /bazar_schedules/{scheduleId} {
        allow read: if isMessMember(messId);
        allow write: if isMessAdmin(messId);
      }

      // ── REQUESTS ──
      match /requests/{requestId} {
        allow read: if isMessMember(messId);
        allow create: if isMessMember(messId)
                      && request.resource.data.user_id == request.auth.uid;
        allow update: if isMessAdmin(messId)
                      && request.resource.data.diff(resource.data).affectedKeys()
                         .hasOnly(['status', 'reviewed_by', 'reviewed_at']);
        allow delete: if false;
      }

      // ── MESSAGES ──
      match /messages/{messageId} {
        allow read: if isMessMember(messId);
        allow create: if isMessMember(messId)
                      && request.resource.data.user_id == request.auth.uid
                      && request.resource.data.message.size() <= 2000;
        allow update, delete: if false;
      }
    }

    // ─────────────────────────────────────────────
    // NOTIFICATIONS COLLECTION
    // ─────────────────────────────────────────────

    match /notifications/{notificationId} {
      allow read: if isAuthenticated()
                  && resource.data.user_id == request.auth.uid;
      allow create: if isAuthenticated(); // cloud functions create these
      allow update: if isAuthenticated()
                    && resource.data.user_id == request.auth.uid
                    && request.resource.data.diff(resource.data).affectedKeys()
                       .hasOnly(['is_read', 'read_at']);
      allow delete: if isAuthenticated()
                    && resource.data.user_id == request.auth.uid;
    }

    // ─────────────────────────────────────────────
    // SUBSCRIPTIONS COLLECTION
    // ─────────────────────────────────────────────

    match /subscriptions/{subscriptionId} {
      allow read: if isAuthenticated()
                  && resource.data.user_id == request.auth.uid;
      allow create, update, delete: if false; // managed by cloud functions / Stripe webhooks
    }
  }
}
```

### 2.2 Security Rules Coverage Matrix

| Operation | Owner | Manager | Member | Non-Member | Auth'd Only | Unauthenticated |
|-----------|-------|---------|--------|------------|-------------|-----------------|
| Read mess details | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Create mess | ✅ (any) | ✅ (any) | ✅ (any) | ✅ (any) | ✅ | ❌ |
| Update mess | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Delete mess | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Add member | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Remove member | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Change role | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Leave mess | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Add own meal | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Edit own meal | ✅ | ✅ | ✅ (if pending) | ❌ | ❌ | ❌ |
| Edit any meal | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Add expense | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Approve expense | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Add deposit | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Approve deposit | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Send message | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Read members | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Read own profile | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

---

## 3. Authentication Flow (Redesigned)

### 3.1 Complete Flow Diagram

```
                         ┌─────────────────────┐
                         │    APP LAUNCH        │
                         │  (Splash / AuthGate) │
                         └──────────┬──────────┘
                                    │
                          ┌─────────▼─────────┐
                          │ FirebaseAuth       │
                          │ .authStateChanges │
                          └──────┬────┬───────┘
                                 │    │
                    user == null │    │ user != null
                                 │    │
                    ┌────────────▼┐   └──────────────────────┐
                    │  Login /     │                          │
                    │  Signup      │                ┌─────────▼──────────┐
                    │  Screen      │                │ Check emailVerified │
                    └──┬───┬───┬──┘                └──────┬──────┬──────┘
                       │   │   │                          │      │
          ┌────────────┘   │   └──────────┐       verified│      │not verified
          ▼                ▼              ▼               │      │
    ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌───────▼──┐ ┌─▼──────────┐
    │  Email   │   │  Phone   │   │  Google  │   │  Fetch    │ │ Show Email │
    │  Login   │   │  Login   │   │  Login   │   │  Profile  │ │ Verify     │
    │          │   │  (OTP)   │   │          │   │  Check    │ │ Screen     │
    └────┬─────┘   └────┬─────┘   └────┬─────┘   └────┬──────┘ └────────────┘
         │              │              │              │
         └──────────────┼──────────────┘              │
                        │                             │
              ┌─────────▼──────────┐                  │
              │ Account Linking    │                  │
              │ Check (if needed)  │                  │
              └─────────┬──────────┘                  │
                        │                             │
                        └──────────────┬──────────────┘
                                       │
                             ┌─────────▼──────────┐
                             │ user_profiles/{uid} │
                             │   .exists?          │
                             └──────┬──────┬──────┘
                                    │      │
                            exists  │      │  not exists
                                    │      │
                          ┌─────────▼──┐ ┌─▼──────────────┐
                          │ Load User  │ │ Create Profile  │
                          │ Memberships│ │ Screen          │
                          └─────┬──────┘ └──────┬──────────┘
                                │               │
                                │     ┌─────────▼──────────┐
                                │     │ On Save → Create    │
                                │     │ user_profiles/{uid} │
                                │     │ users/{uid}        │
                                │     └─────────┬──────────┘
                                │               │
                                └───────┬───────┘
                                        │
                              ┌─────────▼──────────┐
                              │ Has Active Mess?   │
                              └──────┬──────┬──────┘
                                     │      │
                              yes    │      │ no
                                     │      │
                           ┌─────────▼──┐ ┌─▼────────────────┐
                           │ Dashboard  │ │ Create / Join     │
                           │ Home View  │ │ Mess Screen      │
                           └────────────┘ └──────────────────┘
```

### 3.2 Auth Gate (Splash) Logic

```dart
// Pseudocode for AuthGate widget
class AuthGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const SplashScreen(),
      unauthenticated: () => const LoginScreen(),
      emailNotVerified: (user) => const EmailVerificationScreen(),
      noProfile: (user) => const CreateProfileScreen(),
      noMess: (user) => const NoMessScreen(),
      authenticated: (user, memberships) => const DashboardShell(),
    );
  }
}
```

### 3.3 Multi-Provider Auth Service

```dart
// Unified interface
abstract class IAuthService {
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> signUpWithEmail(String email, String password, String name);
  Future<UserCredential> signInWithGoogle();
  Future<void> signInWithPhone(String phone, {required Function(PhoneAuthCredential) onCodeSent});
  Future<UserCredential> verifyPhoneOTP(String verificationId, String smsCode);
  Future<void> signOut();
  Future<void> linkWithGoogle();   // Link additional provider
  Future<void> linkWithPhone(PhoneAuthCredential credential);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> deleteAccount();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}
```

### 3.4 Error Handling Matrix for Auth

| Firebase Error Code | User-Facing Message | Retry? |
|---------------------|---------------------|--------|
| `user-not-found` | "No account found with this email" | Yes |
| `wrong-password` | "Incorrect password" | Yes |
| `email-already-in-use` | "An account already exists with this email" | No |
| `weak-password` | "Password is too weak. Use 8+ characters with a mix of letters, numbers, and symbols" | Yes |
| `invalid-email` | "Please enter a valid email address" | Yes |
| `account-exists-with-different-credential` | "This email is already registered with Google. Please sign in with Google." | No |
| `invalid-verification-code` | "Invalid OTP. Please try again." | Yes |
| `too-many-requests` | "Too many attempts. Please try again later." | No (with countdown) |
| `network-request-failed` | "No internet connection. Please check your network." | Yes |
| `requires-recent-login` | "For security, please sign in again before proceeding." | No |

---

## 4. Role-Based Access Control Architecture

### 4.1 Role Hierarchy

```
Super Admin (system-level, not mess-level)
  │
  ├── Owner (mess creator, full control over one mess)
  │     │
  │     ├── Manager (appointed by Owner, can manage members & approve)
  │     │     │
  │     │     └── Member (basic user in a mess)
  │     │
  │     └── Member
  │
  └── [User can be Owner in Mess A, Manager in Mess B, Member in Mess C]
```

### 4.2 Role Permissions Matrix

| Permission | Super Admin | Owner | Manager | Member |
|------------|:-----------:|:-----:|:-------:|:------:|
| View all messes (system) | ✅ | ❌ | ❌ | ❌ |
| Delete any mess (system) | ✅ | ❌ | ❌ | ❌ |
| Create mess | ✅ | ✅ (own) | ✅ (own) | ✅ (own) |
| Delete own mess | ✅ | ✅ | ❌ | ❌ |
| Update mess details | ✅ | ✅ | ❌ | ❌ |
| Add members | ✅ | ✅ | ✅ | ❌ |
| Remove members | ✅ | ✅ | ❌ | ❌ |
| Change roles | ✅ | ✅ | ✅¹ | ❌ |
| Add/edit own meals | ✅ | ✅ | ✅ | ✅ |
| Edit any meals | ✅ | ✅ | ✅ | ❌ |
| Add expenses | ✅ | ✅ | ✅ | ✅ |
| Approve expenses | ✅ | ✅ | ✅ | ❌ |
| Add deposits | ✅ | ✅ | ✅ | ✅ |
| Approve deposits | ✅ | ✅ | ✅ | ❌ |
| View reports | ✅ | ✅ | ✅ | ✅ |
| Export PDF | ✅ | ✅ | ✅ | ✅ |
| Manage settings | ✅ | ✅ | ✅ | ❌ |
| Send messages | ✅ | ✅ | ✅ | ✅ |
| Leave mess | ❌ | ❌² | ✅ | ✅ |

¹ Manager can only promote to Manager or demote to Member, not make Owner
² Owner cannot leave — must transfer ownership or delete mess

### 4.3 Role Storage Pattern

```dart
// Role enum
enum MessRole {
  owner('owner'),
  manager('manager'),
  member('member');

  const MessRole(this.value);
  final String value;

  bool get canManageMembers => this == owner || this == manager;
  bool get canApprove => this == owner || this == manager;
  bool get canEditSettings => this == owner || this == manager;
  bool get canDeleteMess => this == owner;
  bool get canTransferOwnership => this == owner;
}
```

### 4.4 Firebase Custom Claims (Optional Enhancement)

For Super Admin identification:

```javascript
// Cloud Function — set on user creation
await admin.auth().setCustomUserClaims(uid, { superAdmin: true });

// Client-side check
final idTokenResult = await FirebaseAuth.instance.currentUser!.getIdTokenResult();
final isSuperAdmin = idTokenResult.claims?['superAdmin'] == true;
```

---

## 5. Offline-First Sync Strategy

### 5.1 Architecture Overview

```
┌──────────────────────────────────────────────────────┐
│                    FLUTTER APP                        │
│                                                       │
│  ┌─────────┐    ┌──────────┐    ┌──────────────────┐ │
│  │   UI    │───►│ ViewModel│───►│   Repository     │ │
│  │ (Views) │◄───│ (Riverpod)│◄──│   (Facade)       │ │
│  └─────────┘    └──────────┘    └───────┬──────────┘ │
│                                          │            │
│                      ┌───────────────────┼───────┐    │
│                      │                   │       │    │
│               ┌──────▼──────┐   ┌───────▼──────┐│    │
│               │ Local Data   │   │ Remote Data  ││    │
│               │ Source       │   │ Source       ││    │
│               │ (Isar)       │   │ (Firestore)  ││    │
│               └──────┬──────┘   └───────┬──────┘│    │
│                      │                   │       │    │
│               ┌──────▼──────┐   ┌───────▼──────┐│    │
│               │ Sync Engine  │   │ Network      ││    │
│               │ (Queue +     │◄──│ Monitor      ││    │
│               │  Conflict)   │   │ (connectivity││    │
│               └──────────────┘   │  _plus)      ││    │
│                                  └──────────────┘│    │
└──────────────────────────────────────────────────────┘
```

### 5.2 Isar Schema Design

```dart
// isar_schemas.dart

@collection
class LocalMeal {
  Id id = Isar.autoIncrement;       // Local auto-increment ID
  late String remoteId;              // Firestore document ID (null if pending)
  late String messId;
  late String userId;
  late DateTime date;
  late double breakfast;
  late double lunch;
  late double dinner;
  late String status;
  late SyncStatus syncStatus;        // synced | pending | failed
  late DateTime createdAt;
  late DateTime updatedAt;
  late int version;                  // For conflict resolution
}

@collection
class LocalExpense {
  Id id = Isar.autoIncrement;
  late String remoteId;
  late String messId;
  late String addedBy;
  late double amount;
  late String category;
  late String? description;
  late DateTime date;
  late String status;
  late SyncStatus syncStatus;
  late DateTime createdAt;
  late DateTime updatedAt;
  late int version;
}

@collection
class SyncQueueItem {
  Id id = Isar.autoIncrement;
  late String collection;            // "meals" | "expenses" | "deposits"
  late String documentId;            // Firestore doc ID or temp ID
  late SyncOperation operation;      // create | update | delete
  late String payload;               // JSON-encoded data
  late DateTime queuedAt;
  late int retryCount;
  late SyncPriority priority;        // high | normal | low
  late String? errorMessage;
}

enum SyncStatus { synced, pending, failed, conflict }
enum SyncOperation { create, update, delete }
enum SyncPriority { high, normal, low }
```

### 5.3 Sync Engine Flow

```
┌─────────────────────────────────────────────────┐
│              SYNC ENGINE                         │
│                                                  │
│  1. WRITE PATH (User Action)                     │
│     ┌──────────┐                                │
│     │ User adds │                                │
│     │ expense   │                                │
│     └────┬─────┘                                │
│          ▼                                       │
│     ┌──────────────┐                            │
│     │ Save to Isar  │  ◄── Immediate persistence │
│     │ (syncStatus = │                             │
│     │  pending)     │                             │
│     └────┬─────────┘                            │
│          ▼                                       │
│     ┌──────────────┐                            │
│     │ Add to Sync   │                            │
│     │ Queue         │                            │
│     └────┬─────────┘                            │
│          ▼                                       │
│     ┌──────────────┐                            │
│     │ Update UI     │  ◄── Optimistic update     │
│     │ immediately   │                             │
│     └──────────────┘                            │
│                                                  │
│  2. SYNC PATH (Triggered by connectivity)        │
│     ┌──────────────┐                            │
│     │ Network back  │                            │
│     │ online        │                            │
│     └────┬─────────┘                            │
│          ▼                                       │
│     ┌──────────────┐                            │
│     │ Process queue │  (FIFO, high priority 1st) │
│     │ batch by batch│                            │
│     └────┬─────────┘                            │
│          ▼                                       │
│     ┌──────────────┐     ┌──────────────┐       │
│     │ Write to      │────►│ Mark synced   │       │
│     │ Firestore     │     │ in Isar       │       │
│     └──────┬───────┘     └──────────────┘       │
│            │                                     │
│            │ (on conflict)                       │
│            ▼                                     │
│     ┌──────────────┐                            │
│     │ Conflict      │                            │
│     │ Resolution    │                            │
│     │ (last-write-  │                            │
│     │  wins with    │                            │
│     │  versioning)  │                            │
│     └──────────────┘                            │
│                                                  │
│  3. READ PATH (Data Fetch)                       │
│     ┌──────────────┐                            │
│     │ Read from     │  ◄── Always read local     │
│     │ Isar first    │      first (instant UI)    │
│     └────┬─────────┘                            │
│          ▼                                       │
│     ┌──────────────┐                            │
│     │ Show cached   │                            │
│     │ data in UI    │                            │
│     └────┬─────────┘                            │
│          ▼                                       │
│     ┌──────────────┐                            │
│     │ Fetch from    │  ◄── Background refresh    │
│     │ Firestore     │                             │
│     └────┬─────────┘                            │
│          ▼                                       │
│     ┌──────────────┐                            │
│     │ Merge into    │                            │
│     │ Isar (upsert) │                            │
│     └────┬─────────┘                            │
│          ▼                                       │
│     ┌──────────────┐                            │
│     │ Emit updated  │                            │
│     │ data to UI    │                            │
│     └──────────────┘                            │
└─────────────────────────────────────────────────┘
```

### 5.4 Conflict Resolution Strategy

Since this is a mess-management app (not collaborative editing), use **Last-Write-Wins with Versioning**:

1. Each document has a `version` field (integer, incremented on each write)
2. When syncing, compare local version with remote version
3. If remote version > local version: remote wins (download), local is overwritten
4. If local version > remote version: local wins (upload)
5. If versions equal and both modified: timestamp comparison, most recent wins

For **meal entries** specifically (most likely conflict scenario):
- Each user only edits their own meals → minimal conflict surface
- Admin overrides always win (version bump on admin edit)

### 5.5 Background Sync with WorkManager

```dart
// Android: workmanager package
// iOS: background_fetch package

void registerBackgroundSync() {
  Workmanager().registerPeriodicTask(
    "sync-task",
    "backgroundSync",
    frequency: Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );
}

@pragma('vm:entry-point')
void backgroundSync() {
  // Initialize Isar
  // Initialize Firebase (limited)
  // Process sync queue
  // Send FCM if sync completed
}
```

---

## 6. Production Folder Structure

```
lib/
├── main.dart                                 # Entry point
├── app.dart                                  # MaterialApp.router configuration
├── bootstrap.dart                            # Initialization orchestration
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart                # Static app-wide constants
│   │   ├── api_constants.dart                # Firestore collection paths
│   │   └── ui_constants.dart                 # Spacing, sizing, durations
│   ├── errors/
│   │   ├── app_exception.dart                # Base exception class
│   │   ├── auth_exception.dart               # Auth-specific exceptions
│   │   ├── network_exception.dart            # Connectivity exceptions
│   │   └── sync_exception.dart               # Sync failure exceptions
│   ├── extensions/
│   │   ├── date_extensions.dart
│   │   ├── string_extensions.dart
│   │   └── context_extensions.dart
│   ├── network/
│   │   ├── network_info.dart                 # Connectivity checker
│   │   └── network_monitor.dart              # Connectivity stream
│   ├── router/
│   │   ├── app_router.dart                   # GoRouter configuration
│   │   ├── route_names.dart                  # Named route constants
│   │   └── auth_guard.dart                   # Redirect logic
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── theme_controller.dart
│   ├── utils/
│   │   ├── logger.dart                       # Structured logging
│   │   ├── validators.dart                   # Form validators
│   │   ├── date_utils.dart
│   │   └── invite_code_generator.dart
│   └── di/
│       └── injection_container.dart          # Riverpod provider overrides for testing
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── isar_database.dart            # Isar initialization
│   │   │   ├── local_meal_datasource.dart
│   │   │   ├── local_expense_datasource.dart
│   │   │   ├── local_deposit_datasource.dart
│   │   │   ├── local_member_datasource.dart
│   │   │   ├── local_mess_datasource.dart
│   │   │   └── local_sync_queue_datasource.dart
│   │   └── remote/
│   │       ├── firebase_auth_datasource.dart
│   │       ├── firestore_meal_datasource.dart
│   │       ├── firestore_expense_datasource.dart
│   │       ├── firestore_deposit_datasource.dart
│   │       ├── firestore_member_datasource.dart
│   │       ├── firestore_mess_datasource.dart
│   │       ├── firestore_user_datasource.dart
│   │       └── firestore_notification_datasource.dart
│   ├── models/
│   │   ├── user_model.dart                   # freezed
│   │   ├── user_profile_model.dart
│   │   ├── mess_model.dart
│   │   ├── mess_member_model.dart
│   │   ├── meal_model.dart
│   │   ├── expense_model.dart
│   │   ├── deposit_model.dart
│   │   ├── notification_model.dart
│   │   ├── request_model.dart
│   │   ├── message_model.dart
│   │   ├── bazar_schedule_model.dart
│   │   ├── report_summary_model.dart
│   │   ├── member_balance_model.dart
│   │   └── sync_queue_item_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── mess_repository.dart
│   │   ├── meal_repository.dart
│   │   ├── expense_repository.dart
│   │   ├── deposit_repository.dart
│   │   ├── notification_repository.dart
│   │   ├── report_repository.dart
│   │   ├── chat_repository.dart
│   │   └── sync_repository.dart
│   └── isar_schemas/
│       ├── local_meal_schema.dart
│       ├── local_expense_schema.dart
│       ├── local_deposit_schema.dart
│       ├── local_member_schema.dart
│       ├── local_mess_schema.dart
│       └── sync_queue_schema.dart
│
├── domain/
│   ├── entities/                             # (Optional — if models don't suffice)
│   ├── enums/
│   │   ├── mess_role.dart
│   │   ├── auth_provider.dart
│   │   ├── meal_status.dart
│   │   ├── expense_category.dart
│   │   └── sync_status.dart
│   └── usecases/
│       ├── auth/
│       │   ├── sign_in_with_email.dart
│       │   ├── sign_up_with_email.dart
│       │   ├── sign_in_with_google.dart
│       │   ├── sign_in_with_phone.dart
│       │   └── sign_out.dart
│       ├── mess/
│       │   ├── create_mess.dart
│       │   ├── join_mess.dart
│       │   └── get_user_messes.dart
│       └── meal/
│           ├── save_meal.dart
│           └── get_meals.dart
│
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_providers.dart           # Riverpod providers
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   ├── email_verification_screen.dart
│   │   │   ├── phone_auth_screen.dart
│   │   │   └── create_profile_screen.dart
│   │   └── widgets/
│   │       ├── email_login_form.dart
│   │       ├── phone_login_form.dart
│   │       ├── google_sign_in_button.dart
│   │       └── auth_error_dialog.dart
│   │
│   ├── splash/
│   │   └── splash_screen.dart
│   │
│   ├── dashboard/
│   │   ├── providers/
│   │   │   └── dashboard_providers.dart
│   │   ├── screens/
│   │   │   ├── dashboard_shell.dart          # Scaffold with BottomNav
│   │   │   └── no_mess_screen.dart
│   │   └── widgets/
│   │       ├── mess_switcher.dart            # Switch between messes
│   │       ├── quick_actions.dart
│   │       └── dashboard_summary_card.dart
│   │
│   ├── mess_management/
│   │   ├── providers/
│   │   │   └── mess_providers.dart
│   │   ├── screens/
│   │   │   ├── create_mess_screen.dart
│   │   │   ├── join_mess_screen.dart
│   │   │   ├── mess_details_screen.dart
│   │   │   └── mess_settings_screen.dart
│   │   └── widgets/
│   │       ├── member_list.dart
│   │       ├── member_tile.dart
│   │       ├── role_picker.dart
│   │       └── invite_code_display.dart
│   │
│   ├── meals/
│   │   ├── providers/
│   │   │   └── meal_providers.dart
│   │   ├── screens/
│   │   │   └── meal_entry_screen.dart
│   │   └── widgets/
│   │       ├── meal_portion_selector.dart
│   │       ├── meal_date_picker.dart
│   │       └── meal_history_card.dart
│   │
│   ├── expenses/
│   │   ├── providers/
│   │   │   └── expense_providers.dart
│   │   ├── screens/
│   │   │   ├── expense_list_screen.dart
│   │   │   └── add_expense_screen.dart
│   │   └── widgets/
│   │       ├── expense_card.dart
│   │       ├── expense_category_picker.dart
│   │       └── expense_summary_chart.dart
│   │
│   ├── balances/
│   │   ├── providers/
│   │   │   └── balance_providers.dart
│   │   ├── screens/
│   │   │   ├── balance_summary_screen.dart
│   │   │   └── add_deposit_screen.dart
│   │   └── widgets/
│   │       ├── balance_card.dart
│   │       └── balance_chart.dart
│   │
│   ├── reports/
│   │   ├── providers/
│   │   │   └── report_providers.dart
│   │   ├── screens/
│   │   │   └── report_screen.dart
│   │   └── widgets/
│   │       ├── report_month_picker.dart
│   │       └── report_pdf_preview.dart
│   │
│   ├── chat/
│   │   ├── providers/
│   │   │   └── chat_providers.dart
│   │   ├── screens/
│   │   │   └── chat_screen.dart
│   │   └── widgets/
│   │       ├── chat_bubble.dart
│   │       └── message_input.dart
│   │
│   ├── notifications/
│   │   ├── providers/
│   │   │   └── notification_providers.dart
│   │   ├── screens/
│   │   │   └── notification_list_screen.dart
│   │   └── widgets/
│   │       └── notification_tile.dart
│   │
│   ├── requests/
│   │   ├── providers/
│   │   │   └── request_providers.dart
│   │   ├── screens/
│   │   │   └── approval_screen.dart
│   │   └── widgets/
│   │       └── request_card.dart
│   │
│   ├── profile/
│   │   ├── providers/
│   │   │   └── profile_providers.dart
│   │   ├── screens/
│   │   │   ├── profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   └── widgets/
│   │       └── profile_avatar.dart
│   │
│   └── settings/
│       ├── providers/
│       │   └── settings_providers.dart
│       ├── screens/
│       │   └── settings_screen.dart
│       └── widgets/
│           ├── theme_selector.dart
│           └── account_actions.dart
│
├── services/
│   ├── fcm_service.dart                      # Refactored
│   ├── pdf_service.dart                      # Refactored
│   ├── analytics_service.dart                # Firebase Analytics wrapper
│   ├── crashlytics_service.dart              # Crashlytics wrapper
│   └── remote_config_service.dart            # Remote Config wrapper
│
└── shared/
    ├── widgets/
    │   ├── app_button.dart                   # Unified button
    │   ├── app_text_field.dart
    │   ├── app_card.dart
    │   ├── loading_overlay.dart
    │   ├── error_view.dart
    │   ├── empty_state_view.dart
    │   ├── connectivity_banner.dart
    │   ├── sync_status_indicator.dart
    │   └── responsive_layout.dart
    └── extensions/
        └── ...
```

---

## 7. Flutter Architecture — Layers

### 7.1 Dependency Graph (Target)

```
┌──────────────────────────────────────────────────────┐
│  UI Layer (Features/Screens + Widgets)               │
│  ↓ depends on                                        │
│  Riverpod Providers (State Management)               │
│  ↓ depends on                                        │
│  UseCases (Domain Logic)                             │
│  ↓ depends on                                        │
│  Repositories (Data Coordination)                    │
│  ↓ depends on                                        │
│  DataSources (Local/Remote Implementation)           │
│  ↓ depends on                                        │
│  Isar / FirebaseFirestore / FirebaseAuth             │
└──────────────────────────────────────────────────────┘
```

### 7.2 Provider Structure (Riverpod)

```dart
// ── Auth Providers ──
final authServiceProvider = Provider<IAuthService>((ref) => FirebaseAuthService());

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((user) {
    if (user == null) return const AuthState.unauthenticated();
    if (!user.emailVerified) return AuthState.emailNotVerified(user);
    return AuthState.authenticated(user);
  });
});

final currentUserProvider = Provider<FirebaseUser?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

// ── User Profile Providers ──
final userProfileProvider = FutureProvider<UserProfileModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(userRepositoryProvider).getProfile(user.uid);
});

// ── Mess Providers ──
final activeMessIdProvider = StateProvider<String?>((ref) => null);

final userMembershipsProvider = StreamProvider<List<MessMembership>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(messRepositoryProvider).getUserMemberships(user.uid);
});

final activeMessProvider = FutureProvider<MessModel?>((ref) {
  final messId = ref.watch(activeMessIdProvider);
  if (messId == null) return null;
  return ref.watch(messRepositoryProvider).getMess(messId);
});

// ── Meal Providers ──
final mealsProvider = StreamProvider<List<MealModel>>((ref) {
  final messId = ref.watch(activeMessIdProvider);
  if (messId == null) return [];
  return ref.watch(mealRepositoryProvider).streamMeals(messId);
});

// ── Sync Status Provider ──
final syncStatusProvider = StreamProvider<SyncState>((ref) {
  return ref.watch(syncRepositoryProvider).syncStateStream;
});
```

### 7.3 Repository Pattern Example

```dart
class MealRepository implements IMealRepository {
  final LocalMealDataSource _local;
  final FirestoreMealDataSource _remote;
  final SyncQueueDataSource _syncQueue;
  final NetworkInfo _networkInfo;

  MealRepository(this._local, this._remote, this._syncQueue, this._networkInfo);

  @override
  Stream<List<MealModel>> streamMeals(String messId) async* {
    // 1. Emit cached data immediately
    yield await _local.getMeals(messId);

    // 2. If online, fetch from remote and cache
    if (await _networkInfo.isConnected) {
      try {
        final remoteMeals = await _remote.getMeals(messId);
        await _local.cacheMeals(remoteMeals);
        yield remoteMeals;
      } catch (e) {
        // Already emitted cached data, so this is best-effort
      }
    }
  }

  @override
  Future<void> saveMeal(MealModel meal) async {
    // 1. Save locally immediately
    final localMeal = meal.copyWith(syncStatus: SyncStatus.pending);
    await _local.upsertMeal(localMeal);

    // 2. Add to sync queue
    await _syncQueue.enqueue(
      collection: 'meals',
      documentId: meal.id,
      operation: SyncOperation.create,
      payload: jsonEncode(meal.toJson()),
    );

    // 3. Try to sync immediately if online
    if (await _networkInfo.isConnected) {
      unawaited(_syncQueue.processQueue());
    }
  }
}
```

---

## 8. Composite Index Strategy

### 8.1 Required Indexes (`firebase.json`)

```json
{
  "firestore": {
    "indexes": [
      {
        "collectionGroup": "meals",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "user_id", "order": "ASCENDING" },
          { "fieldPath": "date", "order": "ASCENDING" }
        ]
      },
      {
        "collectionGroup": "meals",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "date", "order": "ASCENDING" },
          { "fieldPath": "status", "order": "ASCENDING" }
        ]
      },
      {
        "collectionGroup": "expenses",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "date", "order": "DESCENDING" },
          { "fieldPath": "status", "order": "ASCENDING" }
        ]
      },
      {
        "collectionGroup": "expenses",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "added_by", "order": "ASCENDING" },
          { "fieldPath": "date", "order": "DESCENDING" }
        ]
      },
      {
        "collectionGroup": "deposits",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "user_id", "order": "ASCENDING" },
          { "fieldPath": "date", "order": "ASCENDING" }
        ]
      },
      {
        "collectionGroup": "deposits",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "date", "order": "ASCENDING" },
          { "fieldPath": "status", "order": "ASCENDING" }
        ]
      },
      {
        "collectionGroup": "notifications",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "user_id", "order": "ASCENDING" },
          { "fieldPath": "is_read", "order": "ASCENDING" },
          { "fieldPath": "created_at", "order": "DESCENDING" }
        ]
      },
      {
        "collectionGroup": "messages",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "created_at", "order": "DESCENDING" }
        ]
      },
      {
        "collectionGroup": "bazar_schedules",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "date", "order": "ASCENDING" }
        ]
      },
      {
        "collectionGroup": "requests",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "status", "order": "ASCENDING" },
          { "fieldPath": "created_at", "order": "DESCENDING" }
        ]
      },
      {
        "collectionGroup": "auth_logs",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "created_at", "order": "DESCENDING" }
        ]
      },
      {
        "collectionGroup": "members",
        "queryScope": "COLLECTION",
        "fields": [
          { "fieldPath": "role", "order": "ASCENDING" },
          { "fieldPath": "joined_at", "order": "ASCENDING" }
        ]
      }
    ]
  }
}
```

---

## 9. Query Optimization Strategy

### 9.1 Pushed Filtering (Not Client-Side)

```dart
// ❌ CURRENT: Fetch all, filter client-side
_firestore.collection('meals').snapshots()
  .map((snap) => snap.docs
    .where((doc) => doc['date'] >= startDate && doc['date'] <= endDate)
    .toList());

// ✅ TARGET: Push filter to Firestore
_firestore.collection('meals')
  .where('date', isGreaterThanOrEqualTo: startTimestamp)
  .where('date', isLessThanOrEqualTo: endTimestamp)
  .where('status', isEqualTo: 'approved')
  .orderBy('date', descending: true)
  .snapshots();
```

### 9.2 Pagination Strategy

```dart
class PaginatedQuery<T> {
  final Query<T> Function(DocumentSnapshot? lastDoc) queryBuilder;
  final int pageSize;

  Future<List<T>> loadNext(DocumentSnapshot? lastDoc) async {
    var query = queryBuilder(lastDoc).limit(pageSize);
    final snapshot = await query.get();
    return snapshot.docs.map((d) => _fromDoc(d)).toList();
  }
}

// Usage
final expensePaginator = PaginatedQuery<ExpenseModel>(
  queryBuilder: (lastDoc) {
    var q = _firestore.collection('expenses')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date', descending: true);
    if (lastDoc != null) q = q.startAfterDocument(lastDoc);
    return q;
  },
  pageSize: 20,
);
```

### 9.3 Caching Strategy

| Data Type | Cache Duration | Invalidation Trigger |
|-----------|---------------|---------------------|
| User profile | Until sign out | Profile update |
| Mess list | 5 minutes | Join/leave/create mess |
| Mess members | Real-time stream | None (live) |
| Meals (past) | 24 hours | New meal added |
| Expenses (past) | 24 hours | New expense added |
| Notifications | Real-time stream | Read/unread toggle |

---

## 10. Refactoring Roadmap (Phased)

### Phase 0: Foundation & Security (Week 1-2)
**CRITICAL — must be done first**

| Task | Priority | Effort |
|------|----------|--------|
| Deploy Firestore Security Rules | 🔴 P0 | 1 day |
| Add `freezed` + `json_serializable` to models | 🟠 P1 | 2 days |
| Fix Google Sign-In token bug (`accessToken`) | 🔴 P0 | 1 hour |
| Delete stale files (`database_schema.sql`, `env.dart`) | 🟠 P1 | 15 min |
| Add Firestore composite indexes | 🔴 P0 | 1 day |
| Add Riverpod + remove GetX dependency | 🟠 P1 | 2 days |
| Add GoRouter + remove GetX navigation | 🟠 P1 | 2 days |
| Wireframe `AuthGate` splash screen | 🟠 P1 | 1 day |

### Phase 1: Auth Overhaul (Week 2-3)

| Task | Priority | Effort |
|------|----------|--------|
| Implement `IAuthService` interface | 🔴 P0 | 1 day |
| Add phone authentication flow | 🔴 P0 | 2 days |
| Add email verification enforcement | 🔴 P0 | 1 day |
| Add user linking (Google ↔ Email) | 🟠 P1 | 1 day |
| Implement password strength validation (8+ chars, mixed) | 🟠 P1 | 2 hours |
| Add `auth_logs` subcollection writes | 🟠 P1 | 1 day |
| Add device session tracking | 🟡 P2 | 1 day |
| Add auth error handling abstraction | 🟠 P1 | 1 day |

### Phase 2: Data Layer (Week 3-5)

| Task | Priority | Effort |
|------|----------|--------|
| Create `users` collection + migration script | 🔴 P0 | 1 day |
| Create `user_profiles` collection + split from `profiles` | 🔴 P0 | 1 day |
| Implement all Firestore datasources | 🔴 P0 | 3 days |
| Implement all repositories | 🔴 P0 | 3 days |
| Rebuild models with `freezed` | 🔴 P0 | 2 days |
| Move date strings → Firestore Timestamps | 🟠 P1 | 2 days |
| Add pagination to all list queries | 🟠 P1 | 2 days |
| Add `subscriptions` collection | 🟡 P2 | 1 day |

### Phase 3: Offline-First (Week 5-7)

| Task | Priority | Effort |
|------|----------|--------|
| Integrate Isar database | 🔴 P0 | 1 day |
| Define Isar schemas for all entities | 🔴 P0 | 2 days |
| Implement local datasources | 🔴 P0 | 3 days |
| Implement sync queue (Isar) | 🔴 P0 | 2 days |
| Implement sync engine | 🔴 P0 | 3 days |
| Implement conflict resolution | 🟠 P1 | 2 days |
| Implement connectivity monitoring | 🟠 P1 | 1 day |
| Add `SyncStatusIndicator` widget | 🟠 P1 | 1 day |
| Register background sync (WorkManager) | 🟡 P2 | 2 days |

### Phase 4: Feature Migration (Week 7-9)

| Task | Priority | Effort |
|------|----------|--------|
| Migrate auth screens to new architecture | 🔴 P0 | 2 days |
| Migrate mess management + role system | 🔴 P0 | 2 days |
| Migrate meal entry feature | 🔴 P0 | 2 days |
| Migrate expense management | 🔴 P0 | 2 days |
| Migrate balance calculator | 🔴 P0 | 2 days |
| Migrate reports + PDF | 🟠 P1 | 2 days |
| Migrate chat feature | 🟠 P1 | 1 day |
| Migrate notifications | 🟠 P1 | 1 day |
| Implement bazar schedule feature | 🟡 P2 | 2 days |
| Implement monthly summary auto-calc | 🟡 P2 | 2 days |
| Implement multi-mess switching | 🔴 P0 | 2 days |

### Phase 5: Production Hardening (Week 9-10)

| Task | Priority | Effort |
|------|----------|--------|
| Add Firebase Analytics events | 🟠 P1 | 1 day |
| Add Crashlytics | 🟠 P1 | 1 day |
| Add Remote Config (feature flags) | 🟡 P2 | 1 day |
| Add proper logging (replace `debugPrint`) | 🟠 P1 | 1 day |
| Write unit tests (repositories, use cases) | 🟠 P1 | 3 days |
| Write integration tests (Firebase emulator) | 🟡 P2 | 2 days |
| Write widget tests (screens) | 🟡 P2 | 2 days |
| Performance profiling & optimization | 🟠 P1 | 2 days |
| CI/CD pipeline setup | 🟡 P2 | 1 day |
| App store deployment prep | 🟡 P2 | 1 day |

### Phase 6: MCP (Multi-Mess Control Panel — Future)

| Task | Priority | Effort |
|------|----------|--------|
| Super Admin dashboard | 🟡 P2 | 3 days |
| Mess analytics for owners | 🟡 P2 | 3 days |
| Bulk operations (Cloud Functions) | 🟡 P2 | 2 days |
| Subscription billing integration | 🟡 P2 | 3 days |

---

## Appendix A: Dependency Changes (pubspec.yaml)

### Packages to ADD:
```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # Navigation
  go_router: ^14.8.1

  # Offline Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1

  # Code Generation (models)
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Utilities
  connectivity_plus: ^6.1.1
  logger: ^2.5.0
  equatable: ^2.0.7
  device_info_plus: ^11.3.0
  package_info_plus: ^8.1.2

  # Firebase (add)
  firebase_analytics: ^11.4.4
  firebase_crashlytics: ^4.3.4
  firebase_remote_config: ^5.4.2
  firebase_storage: ^12.4.4

  # Background Sync
  workmanager: ^0.5.2

dev_dependencies:
  build_runner: ^2.4.14
  freezed: ^2.5.8
  json_serializable: ^6.9.4
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.6.3
  mockito: ^5.4.5
  mocktail: ^1.0.4
  firebase_auth_mocks: ^0.14.1
  fake_cloud_firestore: ^3.1.0

  # Testing
  integration_test:
    sdk: flutter
```

### Packages to REMOVE:
```yaml
  get: ^4.7.3            # Replace with Riverpod
  get_storage: ^2.1.1    # Replace with Isar
```

---

## Appendix B: Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| **Riverpod over GetX** | Better testability, compile-time safety, proper DI, no BuildContext dependency for providers |
| **GoRouter over GetX Navigation** | Declarative routing, deep linking support, redirect guards, better for web support |
| **Subcollections over flat collections** | Security rules scoping, atomic deletes, logical data grouping |
| **freezed for models** | Immutable, copyWith, ==, hashCode, JSON serialization all generated |
| **Repository pattern** | Testable, swappable data sources, offline-first ready |
| **Isar over Drift/Hive** | Best performance for Flutter, rich queries, type-safe, actively maintained |
| **Date as Timestamp (not string)** | Server-side filtering, timezone-safe, proper Firestore indexing |
| **FCM tokens as subcollection** | Multi-device support, easy cleanup, no token clobbering |

---

> **End of Implementation Plan**
>
> Next step: Generate code after receiving approval on this architecture plan.