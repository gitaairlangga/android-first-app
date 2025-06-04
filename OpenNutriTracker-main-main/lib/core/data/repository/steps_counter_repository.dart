import 'package:opennutritracker/core/data/data_source/steps_counter_data_source.dart';
import 'package:opennutritracker/core/data/data_source/tracked_day_data_source.dart';
import 'package:opennutritracker/core/data/dbo/steps_counter_dbo.dart';
import 'package:opennutritracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:opennutritracker/core/domain/entity/steps_counter_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';

class StepsCounterRepository {
  final StepsCounterDataSource _stepsCounterDataSource;

  StepsCounterRepository(this._stepsCounterDataSource);

  Future<List<StepsCounterDbo>> getAllStepsCounterDBO() async {
    return await _stepsCounterDataSource.getAllStepsCounters();
  }

  Future<StepsCounterEntity?> getStepsCounter(DateTime day) async {
    final trackedDay = await _stepsCounterDataSource.getStepsCounter(day);
    if (trackedDay != null) {
      return StepsCounterEntity.fromStepsCounterDBO(trackedDay);
    } else {
      return null;
    }
  }

  Future<bool> hasStepsCounter(DateTime day) async {
    final trackedDay = await getStepsCounter(day);
    if (trackedDay != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<StepsCounterEntity>> getStepsCounterByRange(
      DateTime start, DateTime end) async {
    final List<StepsCounterDbo> trackedDaysDBO =
        await _stepsCounterDataSource.getStepsCountersInRange(start, end);

    return trackedDaysDBO
        .map((trackedDayDBO) =>
          StepsCounterEntity.fromStepsCounterDBO(trackedDayDBO))
        .toList();
  }

  Future<void> updateDailyStepsCounter(DateTime day, int steps, int sensorValue) async {
    _stepsCounterDataSource.updateDailySteps(day, steps, sensorValue);
  }

  Future<void> addNewStepsCounter(
      DateTime day,
      int steps,
      int sensorValue) async {
    _stepsCounterDataSource.saveStepsCounter(StepsCounterDbo(
        day: day,
        steps: steps,
        sensorValue : sensorValue));
  }

  Future<void> addAllStepsCounters(List<StepsCounterDbo> trackedDaysDBO) async {
    await _stepsCounterDataSource.saveAllStepsCounters(trackedDaysDBO);
  }
}
