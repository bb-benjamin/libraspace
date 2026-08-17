// ═══════════════════════════════════════════════════
// FILE: lib/main.dart
//
// PURPOSE: The FIRST file Dart runs when LibraSpace opens.
// Does two things:
//   1. Connects to Firebase
//   2. Starts the app with all providers (whiteboards) ready
//
// Every Flutter app must have a main() function.
// Dart ALWAYS starts executing from main().
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/library_provider.dart';
import 'app.dart';
import 'firebase_options.dart';

// main() is the entry point. Dart starts here.
// "async" = this function waits for slow things (like connecting to Firebase).
void main() async {
  // MUST be first when main() is async.
  // Makes sure Flutter's internal systems are ready before anything else.
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to Firebase using google-services.json we placed in android/app/
  // "await" = stop here and wait until Firebase connection is ready.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // runApp() launches the visible app.
  runApp(
    // MultiProvider wraps the ENTIRE app with our state managers.
    //
    // WHY?
    // Without Provider: to share data between screens you pass it manually
    // from screen to screen to screen — very messy.
    //
    // With Provider: declare your data HERE at the top.
    // ANY screen anywhere in the app reads it directly. No passing needed.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // AuthProvider manages who is logged in.
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        // LibraryProvider manages library data (built in Week 2).
      ],
      child: const LibraSpaceApp(),
    ),
  );
}
