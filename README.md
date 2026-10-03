# LibraSpace

LibraSpace is a Flutter mobile application that helps students find available library spaces and see the current occupancy of different libraries.

The application uses Firebase for authentication, user profiles, library information, visit history and other application data.

## Main Features

- Create an account using email and password
- Sign in and sign out
- View available libraries
- View the number of free seats in each library
- View whether a library is available or full
- View library information
- View crowd/heatmap information
- View visit history
- View user profile information
- Scan QR codes for check-in and check-out
- Delete an account securely by confirming the user's password

## Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- Firebase Cloud Functions
- Provider
- Geolocator
- Mobile Scanner

## Requirements

Before running the project, make sure the following are installed:

- Flutter
- Dart
- Android Studio
- Android SDK
- Android Emulator
- Git

The project was successfully tested using:

- Flutter 3.44.2
- Dart 3.12.2

To check your Flutter installation, run:

```bash
flutter doctor
```

Fix any Android-related problems shown by Flutter Doctor before continuing.

## How to Download the Project

Open a terminal and run:

```bash
git clone https://github.com/bb-benjamin/libraspace.git
```

Then enter the project folder:

```bash
cd libraspace
```

## Install the Flutter Packages

Run:

```bash
flutter pub get
```

Wait until Flutter shows:

```text
Got dependencies!
```

Some packages may show that newer versions are available. This does not stop the application from running.

## Start an Android Emulator

Open Android Studio.

Go to Device Manager and start an Android virtual device.

For example:

```text
Pixel 6
```

Wait until the Android emulator has completely opened.

To check that Flutter can see the emulator, run:

```bash
flutter devices
```

An Android device should appear in the list.

## Run LibraSpace

Run:

```bash
flutter run
```

If more than one device is available, you can run the application on a specific Android emulator.

For example:

```bash
flutter run -d emulator-5554
```

The application should build, install and open automatically on the Android emulator.

## First Time Use

When LibraSpace opens, you will see:

- Sign In
- Create Account

For a new user, select:

```text
Create Account
```

Enter the required information and create an account.

LibraSpace will create the user's Firebase Authentication account and save the user's profile information in Cloud Firestore.

## Firebase

LibraSpace uses Firebase for:

- User authentication
- User profiles
- Library information
- Visit history
- Notifications
- Cloud Functions

The Android Firebase configuration is already included in the project.

An internet connection is required for Firebase features to work.

## Firebase Cloud Functions

Firebase Cloud Functions are located inside:

```text
functions/
```

If the Cloud Functions need to be edited or deployed, Node.js and Firebase CLI will also be required.

To install the Function packages:

```bash
cd functions
npm install
cd ..
```

This is normally not required just to run the Flutter Android application.

## Important Project Folders

```text
libraspace/
│
├── android/          Android configuration
├── assets/           Application assets
├── functions/        Firebase Cloud Functions
├── lib/              Main Flutter source code
├── test/             Flutter tests
├── pubspec.yaml      Flutter packages
├── pubspec.lock      Package versions
├── firebase.json     Firebase configuration
└── README.md         Project instructions
```

Most of the application code is inside:

```text
lib/
```

## Files That Are Not Stored on GitHub

Some files and folders are created automatically by Flutter, Android Studio or Node.js and therefore are not stored on GitHub.

Examples include:

```text
.dart_tool/
build/
android/.gradle/
android/local.properties
functions/node_modules/
.flutter-plugins-dependencies
```

This is normal.

Flutter recreates the required files when you run:

```bash
flutter pub get
```

## Common Problems

### Flutter command is not recognized

Run:

```bash
flutter doctor
```

If the command does not work, Flutter may not be installed correctly or may not be added to the system PATH.

### No Android device found

Run:

```bash
flutter devices
```

If no Android device appears, start an Android emulator from Android Studio.

### Packages are missing

Run:

```bash
flutter pub get
```

### Build problems

Run:

```bash
flutter clean
flutter pub get
flutter run
```

### Firebase information does not load

Make sure the computer has an active internet connection.

## Testing

A fresh copy of this GitHub repository was tested using the following process:

```text
Clone repository
      ↓
flutter pub get
      ↓
Start Android emulator
      ↓
flutter run
      ↓
Application builds
      ↓
Application installs
      ↓
LibraSpace opens successfully
```

The following features were tested successfully:

- Account creation
- Sign in
- Sign out
- Profile information
- Library information
- Library availability
- Firebase connection
- Account deletion using password confirmation

## Important Note

LibraSpace should currently be run as an Android application.

Although Flutter includes folders for Windows, Linux, macOS, iOS and Web, the Firebase configuration for this project has been set up and tested for Android.
