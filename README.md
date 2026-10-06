LibraSpace is a Flutter mobile application that helps students find available library spaces, view live occupancy, compare nearby libraries, and make better decisions about where and when to study.

## Main Features

- Email/password account creation and sign-in
- Live library seat availability
- Total, occupied and free seat counts
- Smart library recommendation based on distance and current availability
- Sort by distance or by most available space
- Filter to show only libraries with free seats
- Live occupancy heatmap
- Historical crowd patterns and “Best time today”
- “I’m heading here” live destination monitoring
- In-app warning if the selected library becomes full
- Alternative-library suggestion when a destination fills up
- QR check-in/check-out
- Visit history
- User profile
- Secure account deletion with password confirmation

## Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging package
- Provider
- Geolocator
- Mobile Scanner

> **Note:** Firebase Cloud Functions source code is included in the repository, but deployed Cloud Functions are not required to run the Android application.

## Tested Environment

LibraSpace was successfully tested using:

- Flutter 3.44.2
- Dart 3.12.2
- Android 15 / API 35
- Android Studio Emulator
- Windows 10

A completely fresh clone of this GitHub repository was tested successfully before submission.

## Requirements

Install the following before running the project:

- Git
- Flutter SDK
- Android Studio
- Android SDK
- Android Emulator

Check the Flutter setup:

```bash
flutter doctor -v
```

Resolve any important Android toolchain or SDK errors before continuing.

## Quick Start

Clone the repository:

```bash
git clone https://github.com/bb-benjamin/libraspace.git
cd libraspace
```

Install Flutter packages:

```bash
flutter pub get
```

You should see:

```text
Got dependencies!
```

Start an Android emulator from **Android Studio > Device Manager**.

Check that Flutter can see the emulator:

```bash
flutter devices
```

Run LibraSpace:

```bash
flutter run
```

If multiple devices are available, use the Android device ID shown by `flutter devices`.

Example:

```bash
flutter run -d emulator-5554
```

> The exact emulator ID may be different on another computer.

## Optional Verification

Run the Flutter analyzer:

```bash
flutter analyze
```

The current project may show informational lint messages such as `const` suggestions or deprecated styling warnings. These do not prevent the application from building or running.

Run the automated test:

```bash
flutter test
```

The repository was tested successfully with:

```text
All tests passed!
```

Build a debug APK:

```bash
flutter build apk --debug
```

A successful build creates:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## First-Time Use

When LibraSpace opens, select either:

- **Sign In**
- **Create Account**

A new account is created through Firebase Authentication, while profile information is stored in Cloud Firestore.

An internet connection is required for Firebase-backed features.

## Firebase

LibraSpace uses Firebase for:

- Authentication
- User profiles
- Live library information
- Visit history
- Historical crowd data
- Real-time Firestore updates

The Android Firebase configuration required to run the existing project is already included in the repository.

A separate Firebase setup is not required simply to run the Android application.

## “I’m Heading Here” Live Monitoring

When a student opens a library that still has space, they can tap:

```text
I'm heading here
```

While LibraSpace is running, the app continues to monitor that library using live Firestore data.

If the selected library changes from having space to being full, LibraSpace automatically:

1. Warns the student that the library is now full.
2. Suggests another library that currently has available seats.

This means the student does not need to remain on the library detail page and repeatedly check the seat count.

### Prototype Limitation

The current implementation provides live monitoring while LibraSpace is running.

For a production version that must deliver an alert after the app has been completely closed or suspended, a server-side push-notification service such as Firebase Cloud Functions with Firebase Cloud Messaging would be required.

## Crowd Prediction

LibraSpace stores historical check-in information by:

- Library
- Day of the week
- Hour of the day

The app uses this data to show:

- Typical hourly busyness
- Current historical crowd insight
- A **Best time today** suggestion based on quieter recorded periods

This is historical-pattern analysis, not an AI prediction model.

## Smart Library Recommendation

The Home screen recommends a library using a rule-based score based on:

- Current seat availability
- Distance from the user

Availability is given more weight than distance.

During debug/emulator testing, if GPS information cannot be obtained, the project uses a debug-only fallback location near KNUST so the location-based features can still be demonstrated.

## Important Project Folders

```text
libraspace/
├── android/          Android configuration
├── assets/           Application assets
├── functions/        Firebase Cloud Functions source code
├── lib/              Main Flutter source code
├── test/             Flutter tests
├── pubspec.yaml      Flutter package configuration
├── pubspec.lock      Locked package versions
├── firebase.json     Firebase configuration
└── README.md         Project instructions
```

## Generated Files Not Stored on GitHub

The following are intentionally not stored in GitHub because Flutter, Gradle, Android Studio or Node.js generate them automatically:

```text
.dart_tool/
build/
android/.gradle/
android/local.properties
functions/node_modules/
.flutter-plugins-dependencies
```

Do not recreate them manually.

## Troubleshooting

### Flutter command is not recognized

Run:

```bash
flutter doctor -v
```

If the command itself is not found, Flutter may not be installed correctly or its `bin` folder may not be in the system PATH.

### No Android device is found

Start an emulator from Android Studio, then run:

```bash
flutter devices
```

### Packages are missing

Run:

```bash
flutter pub get
```

### Many red errors appear immediately after cloning

Do not fix every editor error one by one.

Run:

```bash
flutter pub get
flutter doctor -v
```

Then restart the editor if necessary.

One missing SDK, package restore or Android toolchain component can produce many secondary errors.

### Build fails while downloading Gradle/Android dependencies

Check the internet connection, then run:

```bash
flutter clean
flutter pub get
flutter run
```

### Firebase data does not load

Check that:

- The computer has an internet connection.
- The project is being run as the Android application.
- Firebase Authentication and Firestore are reachable.
- The user is signed in where required.

### Emulator location behaves strangely

Android emulators may not always provide reliable GPS information.

In debug mode, LibraSpace includes a KNUST-area fallback location for demonstration/testing if GPS retrieval fails.

## Fresh-Clone Verification Performed Before Submission

The repository was tested from a completely separate folder using this sequence:

```text
git clone
↓
git status
↓
flutter pub get
↓
flutter analyze
↓
flutter test
↓
flutter build apk --debug
↓
Start Android emulator
↓
flutter devices
↓
flutter run
↓
Sign in
↓
Firebase data loads
↓
Test Home, Library Details, Crowd Prediction, Heatmap, History and Profile
```

The fresh clone successfully:

- Downloaded dependencies
- Passed the Flutter test
- Built a debug Android APK
- Installed on an Android 15 / API 35 emulator
- Opened successfully
- Connected to Firebase
- Loaded library data
- Loaded crowd prediction data
- Loaded the Heatmap
- Loaded visit history
- Loaded the user profile

## Supervisor / Marker Quick Start

For the fastest setup:

```bash
git clone https://github.com/bb-benjamin/libraspace.git
cd libraspace
flutter pub get
flutter devices
flutter run
```

If the application does not start, run:

```bash
flutter doctor -v
```

before modifying the source code.

## Important Note

LibraSpace should currently be evaluated as an **Android application**.

Although Flutter projects can contain folders for Windows, Linux, macOS, iOS and Web, this project has been configured and tested primarily for Android.
