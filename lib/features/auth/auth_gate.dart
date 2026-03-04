import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home_screen.dart';
import 'login_screen.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/services/history_service.dart';
import '../../core/providers/user_profile_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Usuario logado → cargamos perfil
        return FutureBuilder(
          future: _loadProfile(ref),
          builder: (context, profileSnapshot) {

            if (profileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return const HomeScreen();
          },
        );
      },
    );
  }

  Future<void> _loadProfile(WidgetRef ref) async {
    // 🔹 Cargar perfil
    final profileService = UserProfileService();
    final profile = await profileService.loadProfile();

    if (profile != null) {
      ref.read(userProfileProvider.notifier)
          .updateProfile(profile);
    }

    // 🔹 Cargar historial
    final historyService = HistoryService();
    final cloudHistory = await historyService.loadFromCloud();

    if (cloudHistory.isNotEmpty) {
      await historyService.replaceLocalHistory(cloudHistory);
    }
  }
}