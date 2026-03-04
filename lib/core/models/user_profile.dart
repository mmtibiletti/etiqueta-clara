enum GlutenLevel { strict, moderate, mild }
enum LactoseLevel { severe, moderate, mild }

class UserProfile {
  final bool trackGluten;
  final bool trackLactose;

  final GlutenLevel? glutenLevel;
  final LactoseLevel? lactoseLevel;

  final String? nickname;
  final int validatedCount;
  final String? avatar;

  const UserProfile({
    required this.trackGluten,
    required this.trackLactose,
    this.validatedCount = 0,
    this.glutenLevel,
    this.lactoseLevel,
    this.nickname,
    this.avatar,
  });

  UserProfile copyWith({
    bool? trackGluten,
    bool? trackLactose,
    GlutenLevel? glutenLevel,
    LactoseLevel? lactoseLevel,
    String? nickname,
    int? validatedCount,
    String? avatar,
  }) {
    return UserProfile(
      trackGluten: trackGluten ?? this.trackGluten,
      trackLactose: trackLactose ?? this.trackLactose,
      glutenLevel: glutenLevel ?? this.glutenLevel,
      lactoseLevel: lactoseLevel ?? this.lactoseLevel,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      validatedCount: validatedCount ?? this.validatedCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackGluten': trackGluten,
      'trackLactose': trackLactose,
      'glutenLevel': glutenLevel?.name,
      'lactoseLevel': lactoseLevel?.name,
      'nickname': nickname,
      'avatar': avatar,
      'validatedCount': validatedCount,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      trackGluten: json['trackGluten'] ?? true,
      trackLactose: json['trackLactose'] ?? false,
      glutenLevel: json['glutenLevel'] != null
          ? GlutenLevel.values.firstWhere(
            (e) => e.name == json['glutenLevel'],
        orElse: () => GlutenLevel.strict,
      )
          : null,
      lactoseLevel: json['lactoseLevel'] != null
          ? LactoseLevel.values.firstWhere(
            (e) => e.name == json['lactoseLevel'],
        orElse: () => LactoseLevel.severe,
      )
          : null,
      nickname: json['nickname'],
      avatar: json['avatar'],
      validatedCount: json['validatedCount'] ?? 0,
    );
  }

}