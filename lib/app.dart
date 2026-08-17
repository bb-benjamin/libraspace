// ═══════════════════════════════════════════════════
// FILE: lib/app.dart
//
// PURPOSE: The "traffic controller" of LibraSpace.
// Watches AuthProvider and decides which screen to show:
//   loading  → spinning circle (checking if logged in)
//   loggedOut → WelcomeScreen (login/register)
//   loggedIn  → MainShell (full app)
//
// When login state changes, this AUTOMATICALLY switches screens.
// You do NOT write navigation code for login/logout anywhere else.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/home/screens/main_shell.dart';
import 'shared/theme/app_theme.dart';

class LibraSpaceApp extends StatelessWidget {
  const LibraSpaceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the root widget of every Flutter app.
    // Sets up navigation, theming, and the starting screen.
    return MaterialApp(
      title: 'LibraSpace',
      debugShowCheckedModeBanner: false, // removes the red DEBUG banner
      theme: buildAppTheme(), // our custom blue/Poppins theme

      // "home" = the first screen shown.
      // Consumer<AuthProvider> watches AuthProvider.
      // Whenever AuthProvider calls notifyListeners(), this rebuilds.
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // switch checks authProvider.status against each case:
          switch (authProvider.status) {
            case AuthStatus.loading:
              // Still checking Firebase. Show a spinner.
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                  // CircularProgressIndicator = the spinning loading circle
                ),
              );

            case AuthStatus.loggedOut:
              return WelcomeScreen(); // nobody logged in

            case AuthStatus.loggedIn:
              return MainShell(); // full app with tabs
          }
        },
      ),
    );
  }
}
