import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/profile_storage_service.dart';

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final ProfileStorageService _storage;

  UserProfileNotifier(this._storage)
      : super(const UserProfile(
    trackGluten: true,
    trackLactose: true,
    glutenLevel: GlutenLevel.strict,
    lactoseLevel: LactoseLevel.moderate,
  )) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final savedProfile = await _storage.loadProfile();
    if (savedProfile != null) {
      state = savedProfile;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = profile;
    await _storage.saveProfile(profile);
  }
}

final userProfileProvider =
StateNotifierProvider<UserProfileNotifier, UserProfile>(
      (ref) => UserProfileNotifier(ProfileStorageService()),
);