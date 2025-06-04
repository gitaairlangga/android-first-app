import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/data/dbo/steps_counter_dbo.dart';
import 'package:opennutritracker/core/data/dbo/tracked_day_dbo.dart';

class StepsCounterEntity extends Equatable {
  static const maxKcalDifferenceOverGoal = 500;
  static const maxKcalDifferenceUnderGoal = 1000;

  final DateTime day;
  final int steps;
  final int sensorValue;

  const StepsCounterEntity(
      {required this.day,
      required this.steps,
      required this.sensorValue});

  factory StepsCounterEntity.fromStepsCounterDBO(StepsCounterDbo stepsCounterDBO) {
    return StepsCounterEntity(
        day: stepsCounterDBO.day,
        steps: stepsCounterDBO.steps,
        sensorValue: stepsCounterDBO.sensorValue);
  }

  // TODO: make enum class for rating
  // Color getCalendarDayRatingColor(BuildContext context) {
  //   if (_hasExceededMaxKcalDifferenceGoal(calorieGoal, caloriesTracked)) {
  //     return Theme.of(context).colorScheme.primary;
  //   } else {
  //     return Theme.of(context).colorScheme.error;
  //   }
  // }
  //
  // Color getRatingDayTextColor(BuildContext context) {
  //   if (_hasExceededMaxKcalDifferenceGoal(calorieGoal, caloriesTracked)) {
  //     return Theme.of(context).colorScheme.onSecondaryContainer;
  //   } else {
  //     return Theme.of(context).colorScheme.onErrorContainer;
  //   }
  // }
  //
  // Color getRatingDayTextBackgroundColor(BuildContext context) {
  //   if (_hasExceededMaxKcalDifferenceGoal(calorieGoal, caloriesTracked)) {
  //     return Theme.of(context).colorScheme.secondaryContainer;
  //   } else {
  //     return Theme.of(context).colorScheme.errorContainer;
  //   }
  // }

  bool _hasExceededMaxKcalDifferenceGoal(
      double calorieGoal, caloriesTracked) {
    double difference = calorieGoal - caloriesTracked;

    if (calorieGoal < caloriesTracked) {
      return difference.abs() < maxKcalDifferenceOverGoal;
    } else {
      return difference < maxKcalDifferenceUnderGoal;
    }
  }

  @override
  List<Object?> get props => [
        day,
        steps
      ];
}
