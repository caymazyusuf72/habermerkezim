import 'package:mocktail/mocktail.dart';
import 'package:haber_merkezi/domain/repositories/news_repository.dart';
import 'package:haber_merkezi/domain/repositories/bookmark_repository.dart';
import 'package:haber_merkezi/domain/repositories/settings_repository.dart';
import 'package:haber_merkezi/domain/repositories/category_repository.dart';

/// Mock NewsRepository
class MockNewsRepository extends Mock implements NewsRepository {}

/// Mock BookmarkRepository
class MockBookmarkRepository extends Mock implements BookmarkRepository {}

/// Mock SettingsRepository
class MockSettingsRepository extends Mock implements SettingsRepository {}

/// Mock CategoryRepository
class MockCategoryRepository extends Mock implements CategoryRepository {}