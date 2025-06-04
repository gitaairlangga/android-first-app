import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';

part 'steps_counter_dbo.g.dart';

@HiveType(typeId: 16)
@JsonSerializable()
class StepsCounterDbo extends HiveObject {
  @HiveField(0)
  DateTime day;
  @HiveField(1)
  int steps;
  @HiveField(2)
  int sensorValue; //last value from sensor

  StepsCounterDbo(
      {required this.day,
      required this.steps,
      required this.sensorValue});

  factory StepsCounterDbo.fromTrackedDayEntity(StepsCounterDbo entity) {
    return StepsCounterDbo(
        day: entity.day,
        steps: entity.steps,
        sensorValue: entity.sensorValue);
  }

  factory StepsCounterDbo.fromJson(Map<String, dynamic> json) =>
      _$StepsCounterDboFromJson(json);

  Map<String, dynamic> toJson() => _$StepsCounterDboToJson(this);
}
