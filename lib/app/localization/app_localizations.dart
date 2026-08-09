import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('tr'), Locale('en')];
  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizationsDelegate(),
  ];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  bool get _isTurkish => locale.languageCode == 'tr';
  String get appName => 'AGAIN';
  String get previewTitle =>
      _isTurkish ? 'Tasarım Sistemi Önizlemesi' : 'Design System Preview';
  String get previewSubtitle => _isTurkish
      ? 'AGAIN dünyasının erişilebilir ve responsive temel bileşenleri.'
      : 'Accessible, responsive foundations for the world of AGAIN.';
  String get primaryAction =>
      _isTurkish ? 'Yolculuğa Başla' : 'Start the Journey';
  String get secondaryAction =>
      _isTurkish ? 'İkincil Eylem' : 'Secondary Action';
  String get email => _isTurkish ? 'E-posta' : 'Email';
  String get password => _isTurkish ? 'Şifre' : 'Password';
  String get successTitle =>
      _isTurkish ? 'Harika ilerledin' : 'Wonderful progress';
  String get successMessage => _isTurkish
      ? 'Bugünkü öğrenme ritmini tamamladın.'
      : 'You completed today’s learning rhythm.';
  String get errorTitle =>
      _isTurkish ? 'Bir şey yolunda gitmedi' : 'Something went wrong';
  String get errorMessage => _isTurkish
      ? 'Bağlantını kontrol edip yeniden deneyebilirsin.'
      : 'Check your connection and try again.';
  String get emptyTitle =>
      _isTurkish ? 'Henüz bir keşif yok' : 'No discoveries yet';
  String get emptyMessage => _isTurkish
      ? 'İlk hikâyen burada görünecek.'
      : 'Your first story will appear here.';
  String get retry => _isTurkish ? 'Yeniden Dene' : 'Try Again';
  String get notFoundTitle =>
      _isTurkish ? 'Bu yol henüz açılmadı' : 'This path is not open yet';
  String get notFoundMessage => _isTurkish
      ? 'Hüma seni güvenli bir yola geri götürebilir.'
      : 'Hüma can guide you back to a safe path.';
  String get returnToPreview =>
      _isTurkish ? 'Önizlemeye Dön' : 'Return to Preview';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (item) => item.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
