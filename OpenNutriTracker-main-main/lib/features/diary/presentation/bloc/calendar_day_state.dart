part of 'calendar_day_bloc.dart';

abstract class CalendarDayState extends Equatable {
  const CalendarDayState();
}

class CalendarDayInitial extends CalendarDayState {
  @override
  List<Object> get props => [];
}

class CalendarDayLoading extends CalendarDayState {
  @override
  List<Object?> get props => [];
}

class CalendarDayLoaded extends CalendarDayState {
  final TrackedDayEntity? trackedDayEntity;
  final List<UserActivityEntity> userActivityList;
  final List<IntakeEntity> breakfastIntakeList;
  final List<IntakeEntity> lunchIntakeList;
  final List<IntakeEntity> dinnerIntakeList;
  final List<IntakeEntity> snackIntakeList;
  final int stepstaken;
  final double kcalStepsBurned;

  const CalendarDayLoaded(
      this.trackedDayEntity,
      this.userActivityList,
      this.breakfastIntakeList,
      this.lunchIntakeList,
      this.dinnerIntakeList,
      this.snackIntakeList,
      this.stepstaken,
      this.kcalStepsBurned);

  @override
  List<Object?> get props => [trackedDayEntity];
}
