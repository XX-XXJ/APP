// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckInRecordAdapter extends TypeAdapter<CheckInRecord> {
  @override
  final int typeId = 1;

  @override
  CheckInRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckInRecord(
      id: fields[0] as String,
      itemId: fields[1] as String,
      dateTime: fields[2] as DateTime,
      note: fields[3] as String?,
      mood: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CheckInRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemId)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.mood);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckInRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
