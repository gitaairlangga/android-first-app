import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/usecase/add_config_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_steps_counter_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_config_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_steps_counter_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/update_intake_usecase.dart';
import 'package:opennutritracker/core/utils/calc/calorie_goal_calc.dart';
import 'package:opennutritracker/core/utils/calc/macro_calc.dart';
import 'package:opennutritracker/core/utils/calc/unit_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetConfigUsecase _getConfigUsecase;
  final AddConfigUsecase _addConfigUsecase;
  final GetIntakeUsecase _getIntakeUsecase;
  final DeleteIntakeUsecase _deleteIntakeUsecase;
  final UpdateIntakeUsecase _updateIntakeUsecase;
  final GetUserActivityUsecase _getUserActivityUsecase;
  final DeleteUserActivityUsecase _deleteUserActivityUsecase;
  final AddTrackedDayUsecase _addTrackedDayUseCase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final GetStepsCounterUsecase _getStepsCounterUsecase;
  final AddStepsCounterUsecase _addStepsCounterUsecase;
  final GetUserUsecase _getUserUsecase;

  DateTime currentDay = DateTime.now();
  bool usesImperialUnits = false;
  double bodyWeight = 0;

  HomeBloc(
      this._getConfigUsecase,
      this._addConfigUsecase,
      this._getIntakeUsecase,
      this._deleteIntakeUsecase,
      this._updateIntakeUsecase,
      this._getUserActivityUsecase,
      this._deleteUserActivityUsecase,
      this._addTrackedDayUseCase,
      this._getKcalGoalUsecase,
      this._getMacroGoalUsecase,
      this._getStepsCounterUsecase,
      this._addStepsCounterUsecase,
      this._getUserUsecase)
      : super(HomeInitial()) {
    on<LoadItemsEvent>((event, emit) async {
      emit(HomeLoadingState());

      currentDay = DateTime.now();
      final user = await _getUserUsecase.getUserData();
      final configData = await _getConfigUsecase.getConfig();
      usesImperialUnits = configData.usesImperialUnits;
      bodyWeight = user.weightKG;
      final showDisclaimerDialog = !configData.hasAcceptedDisclaimer;

      final breakfastIntakeList = await _getIntakeUsecase.getTodayBreakfastIntake();
      final totalBreakfastKcal = getTotalKcal(breakfastIntakeList);
      final totalBreakfastCarbs = getTotalCarbs(breakfastIntakeList);
      final totalBreakfastFats = getTotalFats(breakfastIntakeList);
      final totalBreakfastProteins = getTotalProteins(breakfastIntakeList);

      final lunchIntakeList = await _getIntakeUsecase.getTodayLunchIntake();
      final totalLunchKcal = getTotalKcal(lunchIntakeList);
      final totalLunchCarbs = getTotalCarbs(lunchIntakeList);
      final totalLunchFats = getTotalFats(lunchIntakeList);
      final totalLunchProteins = getTotalProteins(lunchIntakeList);

      final dinnerIntakeList = await _getIntakeUsecase.getTodayDinnerIntake();
      final totalDinnerKcal = getTotalKcal(dinnerIntakeList);
      final totalDinnerCarbs = getTotalCarbs(dinnerIntakeList);
      final totalDinnerFats = getTotalFats(dinnerIntakeList);
      final totalDinnerProteins = getTotalProteins(dinnerIntakeList);

      final snackIntakeList = await _getIntakeUsecase.getTodaySnackIntake();
      final totalSnackKcal = getTotalKcal(snackIntakeList);
      final totalSnackCarbs = getTotalCarbs(snackIntakeList);
      final totalSnackFats = getTotalFats(snackIntakeList);
      final totalSnackProteins = getTotalProteins(snackIntakeList);

      final stepsTaken = await  _getStepsCounterUsecase.getTodayStepsTaken();
      final totalStepsTaken = stepsTaken != null ? stepsTaken.steps : 0;

      final totalKcalIntake = totalBreakfastKcal +
          totalLunchKcal +
          totalDinnerKcal +
          totalSnackKcal;
      final totalCarbsIntake = totalBreakfastCarbs +
          totalLunchCarbs +
          totalDinnerCarbs +
          totalSnackCarbs;
      final totalFatsIntake = totalBreakfastFats +
          totalLunchFats +
          totalDinnerFats +
          totalSnackFats;
      final totalProteinsIntake = totalBreakfastProteins +
          totalLunchProteins +
          totalDinnerProteins +
          totalSnackProteins;

      final calBurnedBySteps = getCalBurned(totalStepsTaken);

      final userActivities = await _getUserActivityUsecase.getTodayUserActivity();
      final totalKcalActivities =  calBurnedBySteps + userActivities.map((activity) => activity.burnedKcal).toList().sum;

      final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal() + calBurnedBySteps;
      final totalCarbsGoal =
          await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatsGoal =
          await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinsGoal =
          await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);
      final totalStepsGoal = 8000.0;
          //await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

      final totalKcalLeft =
          CalorieGoalCalc.getDailyKcalLeft(totalKcalGoal, totalKcalIntake);

      emit(HomeLoadedState(
          showDisclaimerDialog: showDisclaimerDialog,
          totalKcalDaily: totalKcalGoal,
          totalKcalLeft: totalKcalLeft,
          totalKcalSupplied: totalKcalIntake,
          totalKcalBurned: totalKcalActivities,
          totalCarbsIntake: totalCarbsIntake,
          totalFatsIntake: totalFatsIntake,
          totalCarbsGoal: totalCarbsGoal,
          totalFatsGoal: totalFatsGoal,
          totalProteinsGoal: totalProteinsGoal,
          totalProteinsIntake: totalProteinsIntake,
          totalStepsTaken: totalStepsTaken,
          totalStepsGoal: totalStepsGoal,
          breakfastIntakeList: breakfastIntakeList,
          lunchIntakeList: lunchIntakeList,
          dinnerIntakeList: dinnerIntakeList,
          snackIntakeList: snackIntakeList,
          userActivityList: userActivities,
          usesImperialUnits: usesImperialUnits,
          userEntity: user));
    });
  }

  double getTotalKcal(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalKcal).toList().sum;

  double getTotalCarbs(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalCarbsGram).toList().sum;

  double getTotalFats(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalFatsGram).toList().sum;

  double getTotalProteins(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalProteinsGram).toList().sum;

  void saveConfigData(bool acceptedDisclaimer) async {
    _addConfigUsecase.setConfigDisclaimer(acceptedDisclaimer);
  }

  Future<void> updateIntakeItem(
      String intakeId, Map<String, dynamic> fields) async {
    final dateTime = DateTime.now();
    // Get old intake values
    final oldIntakeObject = await _getIntakeUsecase.getIntakeById(intakeId);
    assert(oldIntakeObject != null);
    final newIntakeObject =
        await _updateIntakeUsecase.updateIntake(intakeId, fields);
    assert(newIntakeObject != null);
    if (oldIntakeObject!.amount > newIntakeObject!.amount) {
      // Amounts shrunk
      await _addTrackedDayUseCase.removeDayCaloriesTracked(
          dateTime, oldIntakeObject.totalKcal - newIntakeObject.totalKcal);
      await _addTrackedDayUseCase.removeDayMacrosTracked(dateTime,
          carbsTracked:
              oldIntakeObject.totalCarbsGram - newIntakeObject.totalCarbsGram,
          fatTracked:
              oldIntakeObject.totalFatsGram - newIntakeObject.totalFatsGram,
          proteinTracked: oldIntakeObject.totalProteinsGram -
              newIntakeObject.totalProteinsGram);
    } else if (newIntakeObject.amount > oldIntakeObject.amount) {
      // Amounts gained
      await _addTrackedDayUseCase.addDayCaloriesTracked(
          dateTime, newIntakeObject.totalKcal - oldIntakeObject.totalKcal);
      await _addTrackedDayUseCase.addDayMacrosTracked(dateTime,
          carbsTracked:
              newIntakeObject.totalCarbsGram - oldIntakeObject.totalCarbsGram,
          fatTracked:
              newIntakeObject.totalFatsGram - oldIntakeObject.totalFatsGram,
          proteinTracked: newIntakeObject.totalProteinsGram -
              oldIntakeObject.totalProteinsGram);
    }
    _updateDiaryPage(dateTime);
  }

  Future<void> deleteIntakeItem(IntakeEntity intakeEntity) async {
    final dateTime = DateTime.now();
    await _deleteIntakeUsecase.deleteIntake(intakeEntity);
    await _addTrackedDayUseCase.removeDayCaloriesTracked(
        dateTime, intakeEntity.totalKcal);
    await _addTrackedDayUseCase.removeDayMacrosTracked(dateTime,
        carbsTracked: intakeEntity.totalCarbsGram,
        fatTracked: intakeEntity.totalFatsGram,
        proteinTracked: intakeEntity.totalProteinsGram);

    _updateDiaryPage(dateTime);
  }

  Future<void> deleteUserActivityItem(UserActivityEntity activityEntity) async {
    final dateTime = DateTime.now();
    await _deleteUserActivityUsecase.deleteUserActivity(activityEntity);
    _addTrackedDayUseCase.reduceDayCalorieGoal(
        dateTime, activityEntity.burnedKcal);

    final carbsAmount = MacroCalc.getTotalCarbsGoal(activityEntity.burnedKcal);
    final fatAmount = MacroCalc.getTotalFatsGoal(activityEntity.burnedKcal);
    final proteinAmount =
        MacroCalc.getTotalProteinsGoal(activityEntity.burnedKcal);

    _addTrackedDayUseCase.reduceDayMacroGoals(dateTime,
        carbsAmount: carbsAmount,
        fatAmount: fatAmount,
        proteinAmount: proteinAmount);
    _updateDiaryPage(dateTime);
  }

  Future<void> _updateDiaryPage(DateTime day) async {
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
  }

  double getCalBurned(langkah) {
    if (usesImperialUnits) {
      bodyWeight = UnitCalc.kgToLbs(bodyWeight);
    } else {
      bodyWeight = bodyWeight.roundToDouble();
    }
    return (langkah * 0.57 * bodyWeight) / 1000;
  }

  Future<void> updateTrackedDayFromStepsTaken(DateTime day, int stepsTaken) async {
    int stepsTakenToday = 0;
    int selisihLangkah = 0 ;
    final hasStepsDay = await _getStepsCounterUsecase.getTrackedDay(day);
    if(hasStepsDay == null){
      await _addStepsCounterUsecase.addNewStepsCounter(day, 1, stepsTaken);
      stepsTakenToday = 1;
      selisihLangkah = 1;
      debugPrint("steps taken $stepsTakenToday");
    }else{
      int lastStepsCounted = hasStepsDay.sensorValue;
      selisihLangkah = (stepsTaken - lastStepsCounted);
      stepsTakenToday = hasStepsDay.steps + selisihLangkah;
      await _addStepsCounterUsecase.updateStepsTaken(day, stepsTakenToday, stepsTaken);
      debugPrint("steps taken $stepsTakenToday sensor value ${stepsTaken} last counted ${lastStepsCounted}");
    }

    final user = await _getUserUsecase.getUserData();
    final configData = await _getConfigUsecase.getConfig();
    final usesImperialUnits = configData.usesImperialUnits;
    double caloriesBurned = getCalBurned(selisihLangkah);

    debugPrint("calories burner $caloriesBurned");


    final hasTrackedDay = await _addTrackedDayUseCase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      // If the tracked day does not exist, create a new one
      final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal(
          totalKcalActivitiesParam: 0); // Exclude persisted activities
      final totalCarbsGoal =
      await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatGoal =
      await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinGoal =
      await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

      await _addTrackedDayUseCase.addNewTrackedDay(
          day, totalKcalGoal, totalCarbsGoal, totalFatGoal, totalProteinGoal);
    }

    final carbsIncrease = MacroCalc.getTotalCarbsGoal(caloriesBurned);
    final fatIncrease = MacroCalc.getTotalFatsGoal(caloriesBurned);
    final proteinIncrease = MacroCalc.getTotalProteinsGoal(caloriesBurned);

    _addTrackedDayUseCase.increaseDayCalorieGoal(day, caloriesBurned);
    _addTrackedDayUseCase.increaseDayMacroGoals(day,
        carbsAmount: carbsIncrease,
        fatAmount: fatIncrease,
        proteinAmount: proteinIncrease);

    _updateDiaryPage(day);
  }


  /// Returns the user's weight in kg or lbs based on the user's config
  String getDisplayWeight(UserEntity user, bool usesImperialUnits) {
    if (usesImperialUnits) {
      return UnitCalc.kgToLbs(user.weightKG).toStringAsFixed(0);
    } else {
      return user.weightKG.roundToDouble().toStringAsFixed(0);
    }
  }
}
