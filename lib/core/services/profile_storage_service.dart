import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileStorageService {
  static const _trackGlutenKey = 'track_gluten';
  static const _trackLactoseKey = 'track_lactose';
  static const _glutenLevelKey = 'gluten_level';
  static const _lactoseLevelKey = 'lactose_level';

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_trackGlutenKey, profile.trackGluten);
    await prefs.setBool(_trackLactoseKey, profile.trackLactose);

    if (profile.glutenLevel != null) {
      await prefs.setInt(
        _glutenLevelKey,
        profile.glutenLevel!.index,
      );
    }

    if (profile.lactoseLevel != null) {
      await prefs.setInt(
        _lactoseLevelKey,
        profile.lactoseLevel!.index,
      );
    }
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final trackGluten = prefs.getBool(_trackGlutenKey);
    final trackLactose = prefs.getBool(_trackLactoseKey);
    final glutenIndex = prefs.getInt(_glutenLevelKey);
    final lactoseIndex = prefs.getInt(_lactoseLevelKey);

    if (trackGluten == null || trackLactose == null) {
      return null;
    }

    return UserProfile(
      trackGluten: trackGluten,
      trackLactose: trackLactose,
      glutenLevel: glutenIndex != null
          ? GlutenLevel.values[glutenIndex]
          : null,
      lactoseLevel: lactoseIndex != null
          ? LactoseLevel.values[lactoseIndex]
          : null,
    );
  }
}