# Haber Merkezim Projesine Katkıda Bulunma (Contributing)

Haber Merkezim projesini geliştirmek için zaman ayırdığınız için teşekkür ederiz! Aşağıdaki kılavuz, projeye kod katkısında bulunurken izlemeniz gereken adımları açıklamaktadır.

## Temel Kurallar

- **Clean Architecture:** Proje, "Clean Architecture" standartlarına göre yapılandırılmıştır (Domain, Data, Presentation katmanları). Lütfen geliştirmelerinizde bu mimari sınırları koruyun.
- **Dil Desteği:** Lütfen projeye ekleyeceğiniz UI metinlerinde `l10n` yapısını (app_localizations) kullanarak Türkçe/İngilizce destekli geliştirme yapın.
- **Format ve Analiz:** Kod göndermeden önce mutlaka kodunuzun statik analizden ve formattan geçtiğine emin olun. Geliştirme ortamınızda şu komutları çalıştırın:
  ```bash
  dart format .
  dart analyze
  ```

## Pull Request Süreci

1. Projeyi fork'layın.
2. Yeni özellik veya hata düzeltmesi için yeni bir branch oluşturun:
   `git checkout -b feature/harika-ozellik`
3. Değişikliklerinizi yapın ve anlamlı commit mesajları ile kaydedin (Aşağıdaki Commit kurallarını inceleyin).
4. Değişikliklerinizi kendi fork'unuza push edin:
   `git push origin feature/harika-ozellik`
5. Orijinal repoya bir Pull Request açın. PR şablonundaki tüm kutucukları işaretlediğinizden emin olun.
6. Proje yöneticileri tarafından kod incelemesi (Code Review) yapılacak ve uygun bulunursa `main` branch'ine dahil edilecektir.

## Commit Mesajı Standartları

Bu proje, Conventional Commits standardını takip etmektedir. Commit atarken şu formatı kullanın:

- `feat:` Yeni bir özellik ekleme
- `fix:` Hata düzeltme
- `docs:` Yalnızca dokümantasyon değişikliği
- `style:` Kod işleyişini etkilemeyen (boşluk, formatlama vb.) değişiklikler
- `refactor:` Ne hata düzelten ne de özellik ekleyen kod düzenlemesi
- `test:` Eksik testleri ekleme veya mevcut testleri düzeltme
- `chore:` Derleme süreci veya yardımcı araçlar ile ilgili güncellemeler

**Örnek:** `feat: kullanici profili ekranina dark mode destegi eklendi`

Tekrar teşekkürler!
