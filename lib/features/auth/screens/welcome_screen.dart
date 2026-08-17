// ═══════════════════════════════════════════════════
// FILE: lib/features/auth/screens/welcome_screen.dart
// PURPOSE: First screen. Shows app name and two buttons.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scaffold = the basic full-screen frame for every screen
    return Scaffold(
      body: Container(
        width: double.infinity, // fill full screen width
        height: double.infinity, // fill full screen height

        decoration: const BoxDecoration(
          // LinearGradient = two colors blending smoothly
          gradient: LinearGradient(
            begin: Alignment.topLeft, // starts top-left
            end: Alignment.bottomRight, // ends bottom-right
            colors: [
              AppColors.primary, // indigo blue at top
              AppColors.secondary, // teal at bottom
            ],
          ),
        ),

        // SafeArea keeps content away from phone notch and status bar
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              // Column stacks widgets VERTICALLY
              mainAxisAlignment: MainAxisAlignment.center, // center vertically
              children: [
                // APP ICON
                const Icon(
                  Icons.local_library_rounded, // built-in Flutter library icon
                  size: 100,
                  color: Colors.white,
                ),

                const SizedBox(height: 24), // 24px empty space
                // APP NAME
                Text(
                  'LibraSpace',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                // TAGLINE
                Text(
                  'Find a library seat near you\nin seconds.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70, // slightly see-through white
                  ),
                ),

                const SizedBox(height: 64),

                // SIGN IN BUTTON
                SizedBox(
                  width: double.infinity, // full-width button
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // white button
                      foregroundColor: AppColors.primary, // blue text
                    ),
                    onPressed: () {
                      // Navigator.push adds a new screen on top
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                    child: const Text('Sign In'),
                  ),
                ),

                const SizedBox(height: 16),

                const SizedBox(height: 40),

                // Small version number at the bottom
                Text(
                  'LibraSpace v1.0',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white38,
                    // Colors.white38 = very faint white — subtle
                  ),
                ),

                // CREATE ACCOUNT BUTTON
                // OutlinedButton = border outline only, no fill
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
