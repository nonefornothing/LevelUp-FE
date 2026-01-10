import 'package:hive/hive.dart';

import '../../domain/entities/streak.dart';

/// Hive model for Streak entity
class StreakHiveModel extends HiveObject {
  late String id;
  late int typeIndex; // StreakType enum index
  late int currentStreak;
  late int longestStreak;
  late int lastCompletedDateMs;
  int? streakStartDateMs;
  late int totalCompletions;
  late int createdAtMs;
  late int updatedAtMs;

  StreakHiveModel();

  StreakHiveModel.fromEntity(Streak streak) {
    id = streak.id;
    typeIndex = streak.type.index;
    currentStreak = streak.currentStreak;
    longestStreak = streak.longestStreak;
    lastCompletedDateMs = streak.lastCompletedDate.millisecondsSinceEpoch;
    streakStartDateMs = streak.streakStartDate?.millisecondsSinceEpoch;
    totalCompletions = streak.totalCompletions;
    createdAtMs = streak.createdAt.millisecondsSinceEpoch;
    updatedAtMs = streak.updatedAt.millisecondsSinceEpoch;
  }

  Streak toEntity() {
    return Streak(
      id: id,
      type: StreakType.values[typeIndex],
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastCompletedDate: DateTime.fromMillisecondsSinceEpoch(lastCompletedDateMs),
      streakStartDate: streakStartDateMs != null
          ? DateTime.fromMillisecondsSinceEpoch(streakStartDateMs!)
          : null,
      totalCompletions: totalCompletions,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    );
  }
}

/// TypeAdapter for StreakHiveModel
class StreakHiveModelAdapter extends TypeAdapter<StreakHiveModel> {
  @override
  final int typeId = 12;

  @override
  StreakHiveModel read(BinaryReader reader) {
    final model = StreakHiveModel();
    model.id = reader.readString();
    model.typeIndex = reader.readInt();
    model.currentStreak = reader.readInt();
    model.longestStreak = reader.readInt();
    model.lastCompletedDateMs = reader.readInt();
    model.streakStartDateMs = reader.readIntOrNull();
    model.totalCompletions = reader.readInt();
    model.createdAtMs = reader.readInt();
    model.updatedAtMs = reader.readInt();
    return model;
  }

  @override
  void write(BinaryWriter writer, StreakHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.typeIndex);
    writer.writeInt(obj.currentStreak);
    writer.writeInt(obj.longestStreak);
    writer.writeInt(obj.lastCompletedDateMs);
    writer.writeIntOrNull(obj.streakStartDateMs);
    writer.writeInt(obj.totalCompletions);
    writer.writeInt(obj.createdAtMs);
    writer.writeInt(obj.updatedAtMs);
  }
}

/// Extension for BinaryReader to handle nullable int
extension BinaryReaderExtension on BinaryReader {
  int? readIntOrNull() {
    final hasValue = readBool();
    if (!hasValue) return null;
    return readInt();
  }
}

/// Extension for BinaryWriter to handle nullable int
extension BinaryWriterExtension on BinaryWriter {
  void writeIntOrNull(int? value) {
    writeBool(value != null);
    if (value != null) {
      writeInt(value);
    }
  }
}

