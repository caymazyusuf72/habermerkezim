import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/interest_tag.dart';
import '../../domain/repositories/interest_tags_repository.dart';
import '../../core/constants/interest_tags.dart';

/// InterestTagsRepository implementasyonu
/// SharedPreferences kullanarak kullanıcının seçtiği hashtag'leri saklar
class InterestTagsRepositoryImpl implements InterestTagsRepository {
  static const String _userInterestTagsKey = 'user_interest_tags';

  @override
  Future<List<InterestTag>> getAllTags() async {
    // Sabit tanımlı tag'leri döndür
    return InterestTags.allTags;
  }

  @override
  Future<InterestTag?> getTagById(String id) async {
    return InterestTags.getTagById(id);
  }

  @override
  Future<void> saveUserInterestTags(List<String> tagIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_userInterestTagsKey, tagIds);
  }

  @override
  Future<List<String>> getUserInterestTags() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_userInterestTagsKey) ?? [];
  }

  @override
  Future<void> clearUserInterestTags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userInterestTagsKey);
  }
}
