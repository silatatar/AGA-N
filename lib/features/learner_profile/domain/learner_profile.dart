enum LearnerAvatar { moon, compass, forest, huma }

extension LearnerAvatarCopy on LearnerAvatar {
  String get label => switch (this) {
    LearnerAvatar.moon => 'Ay ışığı',
    LearnerAvatar.compass => 'Altın pusula',
    LearnerAvatar.forest => 'Zümrüt orman',
    LearnerAvatar.huma => 'Hüma',
  };

  static LearnerAvatar fromStorage(String? value) =>
      LearnerAvatar.values
          .where((avatar) => avatar.name == value)
          .firstOrNull ??
      LearnerAvatar.huma;
}

class LearnerProfile {
  const LearnerProfile({
    required this.displayName,
    required this.avatar,
    this.username,
  });

  final String displayName;
  final String? username;
  final LearnerAvatar avatar;
}
