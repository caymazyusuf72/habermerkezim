import '../entities/interest_tag.dart';

/// InterestTagsRepository - Domain layer interface
/// İlgi alanı hashtag'lerini yönetir
abstract class InterestTagsRepository {
  /// Tüm mevcut hashtag'leri getir
  Future<List<InterestTag>> getAllTags();

  /// Belirli bir hashtag'i ID ile getir
  Future<InterestTag?> getTagById(String id);

  /// Kullanıcının seçtiği hashtag'leri kaydet
  Future<void> saveUserInterestTags(List<String> tagIds);

  /// Kullanıcının seçtiği hashtag'leri getir
  Future<List<String>> getUserInterestTags();

  /// Kullanıcının seçtiği hashtag'leri temizle
  Future<void> clearUserInterestTags();
}
