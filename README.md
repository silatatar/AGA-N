# AGAIN

AGAIN, hikâye ve keşif temelli çok platformlu bir İngilizce öğrenme uygulamasıdır.

## MVP kapsamı

- Premium, responsive Material 3 tasarım sistemi ve açık/koyu tema
- Karşılama, giriş, kayıt ve şifre yenileme ekranları
- Hedef, CEFR seviyesi ve günlük ritim seçimi
- Tohum Vadisi ana paneli ve ilerleme göstergeleri
- Hikâye Meydanı ve tamamlanabilir ilk etkileşimli hikâye
- Kişisel kelime bahçesi
- Hûma ile yerel sohbet demosu
- Profil ve tema tercihleri

## Çalıştırma

Flutter SDK kurulduktan sonra:

```powershell
flutter pub get
flutter run
```

Windows'ta proje yolunda Türkçe büyük `İ` bulunması bazı Dart sürümlerinde yol çözümleme hatasına neden olabilir. Böyle bir durumda klasörü `AGAIN` gibi yalnızca ASCII karakterli bir ada taşıyın.

## Servis sınırları

Kimlik doğrulama, bulut verisi, canlı Hûma yapay zekâsı, ses tanıma ve ödeme servisleri bu MVP'de yerel demo akışı olarak sunulur. Gizli anahtarlar Flutter istemcisine eklenmemelidir; canlı entegrasyonlar `Flutter → güvenli backend → servis` düzeninde yapılmalıdır.
