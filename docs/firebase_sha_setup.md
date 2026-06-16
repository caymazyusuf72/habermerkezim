# Firebase SHA Parmak İzleri Kurulum Rehberi

## Release Keystore Bilgileri

**Keystore Dosyası:** `haber-merkezi-key.jks`
**Alias:** `haber-merkezi`
**Lokasyon:** Proje kök dizini

## Parmak İzleri

### SHA-1 (Release)
```
27:87:5A:12:2F:2A:B8:DD:40:58:1D:B3:AD:F3:1B:17:3A:E4:72:E8
```

### SHA-256 (Release)
```
45:2F:79:8C:1B:6E:17:6D:0F:01:10:B0:00:1A:F4:E4:1C:4F:50:C4:9C:15:AC:98:4F:78:34:E3:AD:E1:B1:DA
```

## Firebase Console'da Kurulum Adımları

1. **Firebase Console'a Giriş**
   - https://console.firebase.google.com adresine gidin
   - Google hesabınızla giriş yapın

2. **Proje Ayarlarına Gidin**
   - Haber Merkezi projesini seçin
   - Sol üstteki ⚙️ (Settings) ikonuna tıklayın
   - "Project settings" seçeneğine tıklayın

3. **Android Uygulaması Ayarları**
   - "Your apps" sekmesine gidin
   - Android uygulamanızı (`com.habermerkezi.app`) bulun
   - Aşağı kaydırın ve "SHA certificate fingerprints" bölümüne gidin

4. **Parmak İzlerini Ekleyin**
   - "Add fingerprint" butonuna tıklayın
   - SHA-1 parmak izini yapıştırın: `27:87:5A:12:2F:2A:B8:DD:40:58:1D:B3:AD:F3:1B:17:3A:E4:72:E8`
   - Kaydedin
   - Tekrar "Add fingerprint" butonuna tıklayın
   - SHA-256 parmak izini yapıştırın: `45:2F:79:8C:1B:6E:17:6D:0F:01:10:B0:00:1A:F4:E4:1C:4F:50:C4:9C:15:AC:98:4F:78:34:E3:AD:E1:B1:DA`
   - Kaydedin

5. **google-services.json Güncelleme**
   - Parmak izlerini ekledikten sonra
   - "google-services.json" dosyasını indirin
   - İndirilen dosyayı `android/app/google-services.json` konumuna kopyalayın (eski dosyanın üzerine yazın)

6. **Yeni Release APK Oluşturma**
   - Terminal'de şu komutu çalıştırın:
   ```bash
   flutter build apk --release
   ```
   - Yeni APK: `build/app/outputs/flutter-apk/app-release.apk`

## Sorun Giderme

### "Giriş Başarısız" Hatası
Bu hata genellikle Firebase Console'da SHA parmak izlerinin eksik olmasından kaynaklanır. Yukarıdaki adımları takip ederek parmak izlerini ekleyin.

### Debug vs Release
- **Debug APK**: Otomatik olarak debug keystore kullanır (Firebase'de zaten kayıtlı)
- **Release APK**: Release keystore kullanır (yukarıdaki parmak izlerini Firebase'e eklemeniz gerekir)

### Parmak İzlerini Yeniden Almak
Eğer keystore dosyanızı kaybederseniz veya değiştirirseniz:
```bash
keytool -list -v -keystore haber-merkezi-key.jks -alias haber-merkezi -storepass habermerkezi123 -keypass habermerkezi123
```

## Güvenlik Notları

⚠️ **ÖNEMLİ:**
- `haber-merkezi-key.jks` dosyasını ve `key.properties` dosyasını asla Git'e eklemeyin
- Keystore şifresini güvenli bir yerde saklayın
- Keystore dosyasını kaybederseniz, Google Play Store'da uygulama güncelleyemezsiniz

## Test Etme

Parmak izlerini ekledikten ve yeni APK'yı oluşturduktan sonra:

1. Eski APK'yı cihazdan kaldırın
2. Yeni APK'yı yükleyin
3. Google ile giriş yapın
4. Giriş başarılı olmalı ✅

## Doğrulama

Firebase Console'da parmak izlerinin doğru eklendiğini kontrol edin:
- Project Settings > Your apps > Android app
- SHA certificate fingerprints bölümünde her iki parmak izi de görünmeli

---

**Son Güncelleme:** 16 Ocak 2026
**Keystore Oluşturma Tarihi:** 15 Eylül 2025
**Geçerlilik:** 31 Ocak 2053'e kadar