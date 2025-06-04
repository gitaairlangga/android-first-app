// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steps_counter_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StepsCounterDboAdapter extends TypeAdapter<StepsCounterDbo> {
  @override
  final int typeId = 16;

  @override
  StepsCounterDbo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepsCounterDbo(
      day: fields[0] as DateTime,
      steps: fields[1] as int,
      sensorValue: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StepsCounterDbo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.steps)
      ..writeByte(2)
      ..write(obj.sensorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepsCounterDboAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepsCounterDbo _$StepsCounterDboFromJson(Map<String, dynamic> json) =>
    StepsCounterDbo(
      day: DateTime.parse(json['day'] as String),
      steps: (json['steps'] as num).toInt(),
      sensorValue: (json['sensorValue'] as num).toInt(),
    );

Map<String, dynamic> _$StepsCounterDboToJson(StepsCounterDbo instance) =>
    <String, dynamic>{
      'day': instance.day.toIso8601String(),
      'steps': instance.steps,
      'sensorValue': instance.sensorValue,
    };
