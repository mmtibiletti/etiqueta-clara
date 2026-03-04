import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/user_profile.dart';
import '../../core/providers/user_profile_provider.dart';
import '../../core/services/user_profile_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final userProfileService = UserProfileService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Gluten',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Controlar Gluten'),
            value: profile.trackGluten,
            onChanged: (value) async {
              final updatedProfile =
              profile.copyWith(trackGluten: value);

              ref.read(userProfileProvider.notifier)
                  .updateProfile(updatedProfile);

              await userProfileService.saveProfile(updatedProfile);
            },
          ),
          if (profile.trackGluten)
            DropdownButtonFormField<GlutenLevel>(
              value: profile.glutenLevel,
              items: GlutenLevel.values
                  .map(
                    (level) => DropdownMenuItem(
                  value: level,
                  child: Text(level.name),
                ),
              )
                  .toList(),
              onChanged: (value) async {
                if (value == null) return;

                final updatedProfile =
                profile.copyWith(glutenLevel: value);

                ref.read(userProfileProvider.notifier)
                    .updateProfile(updatedProfile);

                await userProfileService.saveProfile(updatedProfile);
              },
              decoration:
              const InputDecoration(labelText: 'Nivel Gluten'),
            ),
          const SizedBox(height: 24),
          const Text(
            'Lactosa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Controlar Lactosa'),
            value: profile.trackLactose,
            onChanged: (value) async {
              final updatedProfile =
              profile.copyWith(trackLactose: value);

              ref.read(userProfileProvider.notifier)
                  .updateProfile(updatedProfile);

              await userProfileService.saveProfile(updatedProfile);
            },
          ),
          if (profile.trackLactose)
            DropdownButtonFormField<LactoseLevel>(
              value: profile.lactoseLevel,
              items: LactoseLevel.values
                  .map(
                    (level) => DropdownMenuItem(
                  value: level,
                  child: Text(level.name),
                ),
              )
                  .toList(),
              onChanged: (value) async {
                if (value == null) return;

                final updatedProfile =
                profile.copyWith(lactoseLevel: value);

                ref.read(userProfileProvider.notifier)
                    .updateProfile(updatedProfile);

                await userProfileService.saveProfile(updatedProfile);
              },
              decoration:
              const InputDecoration(labelText: 'Nivel Lactosa'),
            ),
        ],
      ),
    );
  }
}