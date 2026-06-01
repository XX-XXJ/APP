// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckInItemAdapter extends TypeAdapter<CheckInItem> {
  @override
  final int typeId = 0;

  @override
  CheckInItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckInItem(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCodePoint: fields[2] as int,
      colorValue: fields[3] as int,
      reminderTime: fields[4] as String?,
      reminderDays: (fields[5] as List?)?.cast<int>(),
      createdAt: fields[6] as DateTime?,
      sortOrder: fields[7] as int,
      isActive: fields[8] as bool,
      description: fields[9] as String?,
      frequency: fields[10] as int,
      customDays: (fields[11] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, CheckInItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.reminderTime)
      ..writeByte(5)
      ..write(obj.reminderDays)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.sortOrder)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.frequency)
      ..writeByte(11)
      ..write(obj.customDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckInItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
