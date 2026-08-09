enum LearnerType { child, teen, adult }

extension LearnerTypeCopy on LearnerType {
  String get storageValue => name;

  String get title => switch (this) {
    LearnerType.child => 'Çocuk',
    LearnerType.teen => 'Genç',
    LearnerType.adult => 'Yetişkin',
  };

  String get ageRange => switch (this) {
    LearnerType.child => '7–12',
    LearnerType.teen => '13–17',
    LearnerType.adult => '18+',
  };

  String get description => switch (this) {
    LearnerType.child => 'Güvenli, görsel ve kısa keşifler',
    LearnerType.teen => 'Modern, sosyal ve etkileşimli hikâyeler',
    LearnerType.adult => 'Pratik, zarif ve hedef odaklı öğrenme',
  };

  String get accessibilityDescription => switch (this) {
    LearnerType.child => '7–12 yaş için çocuk öğrenme profili',
    LearnerType.teen => '13–17 yaş için genç öğrenme profili',
    LearnerType.adult => '18 yaş ve üzeri yetişkin öğrenme profili',
  };

  static LearnerType? fromStorage(String? value) {
    for (final type in LearnerType.values) {
      if (type.storageValue == value) return type;
    }
    return null;
  }
}
