import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/dbo/steps_counter_dbo.dart';
import 'package:opennutritracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:opennutritracker/core/utils/extensions.dart';

class StepsCounterDataSource {
  final log = Logger('StepsCounterDataSource');
  final Box<StepsCounterDbo> _stepsCounterBox;

  StepsCounterDataSource(this._stepsCounterBox);

  Future<void> saveStepsCounter(StepsCounterDbo stepsCounterDBO) async {
    log.fine('Updating tracked day in db');
    _stepsCounterBox.put(stepsCounterDBO.day.toParsedDay(), stepsCounterDBO);
  }

  Future<void> saveAllStepsCounters(List<StepsCounterDbo> stepsCounterDBOList) async {
    log.fine('Updating tracked days in db');
    _stepsCounterBox.putAll({
      for (var stepsCounterDBO in stepsCounterDBOList)
        stepsCounterDBO.day.toParsedDay(): stepsCounterDBO
    });
  }

  Future<List<StepsCounterDbo>> getAllStepsCounters() async {
    return _stepsCounterBox.values.toList();
  }

  Future<StepsCounterDbo?> getStepsCounter(DateTime day) async {
    return _stepsCounterBox.get(day.toParsedDay());
  }

  Future<List<StepsCounterDbo>> getStepsCountersInRange(
      DateTime start, DateTime end) async {
    List<StepsCounterDbo> trackedDays = _stepsCounterBox.values
        .where((trackedDay) =>
            (trackedDay.day.isAfter(start) && trackedDay.day.isBefore(end)))
        .toList();
    return trackedDays;
  }

  Future<bool> hasStepsCounter(DateTime day) async =>
      _stepsCounterBox.get(day.toParsedDay()) != null;

  Future<void> updateDailySteps(DateTime day, int steps, int sensorValue) async {
    log.fine('Updating tracked day total calories');
    final updateDay = await getStepsCounter(day);

    if (updateDay != null) {
      updateDay.steps = steps;
      updateDay.sensorValue = sensorValue;
      updateDay.save();
    }
  }

}
