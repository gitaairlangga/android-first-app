import 'package:opennutritracker/core/data/repository/steps_counter_repository.dart';
import 'package:opennutritracker/core/domain/entity/steps_counter_entity.dart';

class GetStepsCounterUsecase {
  final StepsCounterRepository _stepsCounterRepository;

  GetStepsCounterUsecase(this._stepsCounterRepository);

  Future<StepsCounterEntity?> getTrackedDay(DateTime day) async {
    return await _stepsCounterRepository.getStepsCounter(day);
  }

  Future<List<StepsCounterEntity>> getTrackedDaysByRange(
      DateTime start, DateTime end) {
    return _stepsCounterRepository.getStepsCounterByRange(start, end);
  }

  Future<StepsCounterEntity?> getTodayStepsTaken() async =>
      await getTrackedDay(DateTime.now());
}
