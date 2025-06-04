import 'package:opennutritracker/core/data/repository/steps_counter_repository.dart';
import 'package:opennutritracker/core/data/repository/tracked_day_repository.dart';

class AddStepsCounterUsecase {
  final StepsCounterRepository _stepsCounterRepository;

  AddStepsCounterUsecase(this._stepsCounterRepository);

  Future<void> updateStepsTaken(DateTime day, int steps, int sensorValue) async {
    await _stepsCounterRepository.updateDailyStepsCounter(day, steps, sensorValue);
  }

  Future<bool> hasStepsCounter(DateTime day) async {
    return await _stepsCounterRepository.hasStepsCounter(day);
  }

  Future<void> addNewStepsCounter(
      DateTime day,
      int steps,
      int sensorValue) async {
    return await _stepsCounterRepository.addNewStepsCounter(
        day, steps, sensorValue);
  }
}
