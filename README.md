# bachelorpoints

A new Flutter project.

# Getting SHA-1 and SHA-256 Keys for Flutter Projects

This guide explains how to obtain the **SHA-1** and **SHA-256** certificate fingerprints required for services like **Firebase Authentication**, **Google Sign-In**, **Google Maps**, and other Google APIs.

---

# Windows

## Method 1: Using Gradle (Recommended)

1. Open **Command Prompt** or **PowerShell**.
2. Navigate to your Flutter project's Android directory:

```bash
cd android
```

3. Run the following command:

```bash
gradlew signingReport
```

If you are using PowerShell:

```powershell
.\gradlew signingReport
```

4. The output will display all signing configurations.

Example:

```text
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA-256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

---

## Method 2: Using keytool (Debug Keystore)

Run:

```bash
keytool -list -v ^
-alias androiddebugkey ^
-keystore %USERPROFILE%\.android\debug.keystore ^
-storepass android ^
-keypass android
```

---

## Method 3: Using a Release Keystore

```bash
keytool -list -v ^
-keystore C:\path\to\upload-keystore.jks ^
-alias your_alias_name
```

You will be prompted for the keystore password.

---

# macOS

## Method 1: Using Gradle (Recommended)

1. Open **Terminal**.
2. Navigate to the Android folder:

```bash
cd android
```

3. Run:

```bash
./gradlew signingReport
```

If you receive a permission error:

```bash
chmod +x gradlew
./gradlew signingReport
```

Example output:

```text
Variant: debug
Config: debug
Store: /Users/yourname/.android/debug.keystore
Alias: AndroidDebugKey
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA-256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

---

## Method 2: Using keytool (Debug Keystore)

```bash
keytool -list -v \
-alias androiddebugkey \
-keystore ~/.android/debug.keystore \
-storepass android \
-keypass android
```

---

## Method 3: Using a Release Keystore

```bash
keytool -list -v \
-keystore /path/to/upload-keystore.jks \
-alias your_alias_name
```

You will be prompted for the keystore password.

---

# Troubleshooting

## keytool: command not found

### Windows

Verify Java installation:

```bash
java -version
```

Locate keytool:

```bash
where keytool
```

---

### macOS

Verify Java installation:

```bash
java -version
```

Locate keytool:

```bash
which keytool
```

---

# Firebase and Google Services

For production applications, it is recommended to register both:

* Debug SHA-1
* Debug SHA-256
* Release SHA-1
* Release SHA-256

These fingerprints may be required for:

* Firebase Authentication
* Google Sign-In
* Google Maps SDK
* Dynamic Links
* App Integrity APIs
* Other Google Cloud services

---

# Recommended Approach

The easiest and most reliable method is:

```bash
cd android
```

Windows:

```bash
gradlew signingReport
```

macOS:

```bash
./gradlew signingReport
```

This command automatically displays all available SHA-1 and SHA-256 fingerprints for both debug and release builds.
