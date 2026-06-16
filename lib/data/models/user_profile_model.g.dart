// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 1;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      id: fields[0] as String,
      name: fields[1] as String?,
      email: fields[2] as String?,
      avatarUrl: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      stats: fields[5] as UserStatsModel,
      preferences: fields[6] as UserPreferencesModel,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.stats)
      ..writeByte(6)
      ..write(obj.preferences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatsModelAdapter extends TypeAdapter<UserStatsModel> {
  @override
  final int typeId = 2;

  @override
  UserStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStatsModel(
      totalArticlesRead: fields[0] as int,
      totalFavorites: fields[1] as int,
      totalReadingList: fields[2] as int,
      streakDays: fields[3] as int,
      categoryReadCount: (fields[4] as Map).cast<String, int>(),
      lastReadDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserStatsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.totalArticlesRead)
      ..writeByte(1)
      ..write(obj.totalFavorites)
      ..writeByte(2)
      ..write(obj.totalReadingList)
      ..writeByte(3)
      ..write(obj.streakDays)
      ..writeByte(4)
      ..write(obj.categoryReadCount)
      ..writeByte(5)
      ..write(obj.lastReadDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserPreferencesModelAdapter extends TypeAdapter<UserPreferencesModel> {
  @override
  final int typeId = 3;

  @override
  UserPreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferencesModel(
      favoriteCategories: (fields[0] as List).cast<String>(),
      blockedSources: (fields[1] as List).cast<String>(),
      enableNotifications: fields[2] as bool,
      preferredLanguage: fields[3] as String,
      interestTags: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferencesModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.favoriteCategories)
      ..writeByte(1)
      ..write(obj.blockedSources)
      ..writeByte(2)
      ..write(obj.enableNotifications)
      ..writeByte(3)
      ..write(obj.preferredLanguage)
      ..writeByte(4)
      ..write(obj.interestTags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
