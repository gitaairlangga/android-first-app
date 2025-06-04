import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/activity_vertial_list.dart';
import 'package:opennutritracker/core/presentation/widgets/edit_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/delete_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/home/presentation/widgets/dashboard_widget.dart';
import 'package:opennutritracker/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:pedometer/pedometer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;


  final log = Logger('HomePage');

  late HomeBloc _homeBloc;
  bool _isDragging = false;
  String pedestrianStatus = "";

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = locator<HomeBloc>();
    initPlatformState();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _homeBloc,
      builder: (context, state) {
        if (state is HomeInitial) {
          _homeBloc.add(const LoadItemsEvent());
          return _getLoadingContent();
        } else if (state is HomeLoadingState) {
          return _getLoadingContent();
        } else if (state is HomeLoadedState) {
          return _getLoadedContent(
              context,
              state.showDisclaimerDialog,
              state.totalKcalDaily,
              state.totalKcalLeft,
              state.totalKcalSupplied,
              state.totalKcalBurned,
              state.totalCarbsIntake,
              state.totalFatsIntake,
              state.totalProteinsIntake,
              state.totalStepsTaken,
              state.totalCarbsGoal,
              state.totalFatsGoal,
              state.totalProteinsGoal,
              state.totalStepsGoal,
              state.breakfastIntakeList,
              state.lunchIntakeList,
              state.dinnerIntakeList,
              state.snackIntakeList,
              state.userActivityList,
              state.usesImperialUnits);
        } else {
          return _getLoadingContent();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log.info('App resumed');
      _refreshPageOnDayChange();
    }
    super.didChangeAppLifecycleState(state);
  }

  Widget _getLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _getLoadedContent(
      BuildContext context,
      bool showDisclaimerDialog,
      double totalKcalDaily,
      double totalKcalLeft,
      double totalKcalSupplied,
      double totalKcalBurned,
      double totalCarbsIntake,
      double totalFatsIntake,
      double totalProteinsIntake,
      int totalStepStaken, // NEW
      double totalCarbsGoal,
      double totalFatsGoal,
      double totalProteinsGoal,
      double totalStepsGoal, //NEW
      List<IntakeEntity> breakfastIntakeList,
      List<IntakeEntity> lunchIntakeList,
      List<IntakeEntity> dinnerIntakeList,
      List<IntakeEntity> snackIntakeList,
      List<UserActivityEntity> userActivities,
      bool usesImperialUnits) {
    if (showDisclaimerDialog) {
      _showDisclaimerDialog(context);
    }
    return Stack(children: [
      ListView(children: [
        DashboardWidget(
          totalKcalDaily: totalKcalDaily,
          totalKcalLeft: totalKcalLeft,
          totalKcalSupplied: totalKcalSupplied,
          totalKcalBurned: totalKcalBurned,
          totalCarbsIntake: totalCarbsIntake,
          totalFatsIntake: totalFatsIntake,
          totalProteinsIntake: totalProteinsIntake,
          totalStepStaken: totalStepStaken,
          totalCarbsGoal: totalCarbsGoal,
          totalFatsGoal: totalFatsGoal,
          totalProteinsGoal: totalProteinsGoal,
          totalStepsGoal : totalStepsGoal
        ),
        stepsCounterContainer(totalStepStaken),
        ActivityVerticalList(
          day: DateTime.now(),
          title: S.of(context).activityLabel,
          userActivityList: userActivities,
          onItemLongPressedCallback: onActivityItemLongPressed,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).breakfastLabel,
          listIcon: IntakeTypeEntity.breakfast.getIconData(),
          addMealType: AddMealType.breakfastType,
          intakeList: breakfastIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).lunchLabel,
          listIcon: IntakeTypeEntity.lunch.getIconData(),
          addMealType: AddMealType.lunchType,
          intakeList: lunchIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).dinnerLabel,
          addMealType: AddMealType.dinnerType,
          listIcon: IntakeTypeEntity.dinner.getIconData(),
          intakeList: dinnerIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).snackLabel,
          listIcon: IntakeTypeEntity.snack.getIconData(),
          addMealType: AddMealType.snackType,
          intakeList: snackIntakeList,
          onDeleteIntakeCallback: onDeleteIntake,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          usesImperialUnits: usesImperialUnits,
        ),
        const SizedBox(height: 48.0)
      ]),
      Align(
          alignment: Alignment.bottomCenter,
          child: Visibility(
              visible: _isDragging,
              child: Container(
                height: 70,
                color: Theme.of(context).colorScheme.error
                  ..withValues(alpha: 0.3),
                child: DragTarget<IntakeEntity>(
                  onAcceptWithDetails: (data) {
                    _confirmDelete(context, data.data);
                  },
                  onLeave: (data) {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return const Center(
                      child: Icon(
                        Icons.delete_outline,
                        size: 36,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              )))
    ]);
  }

  void onActivityItemLongPressed(
      BuildContext context, UserActivityEntity activityEntity) async {
    final deleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (deleteIntake != null) {
      _homeBloc.deleteUserActivityItem(activityEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
      }
    }
  }

  void onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity) async {
    final deleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (deleteIntake != null) {
      _homeBloc.deleteIntakeItem(intakeEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
      }
    }
  }

  void onIntakeItemDrag(bool isDragging) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDragging = isDragging;
      });
    });
  }

  void onIntakeItemTapped(BuildContext context, IntakeEntity intakeEntity,
      bool usesImperialUnits) async {
    final changeIntakeAmount = await showDialog<double>(
        context: context,
        builder: (context) => EditDialog(
            intakeEntity: intakeEntity, usesImperialUnits: usesImperialUnits));
    if (changeIntakeAmount != null) {
      _homeBloc.updateIntakeItem(intakeEntity.id, {'amount': changeIntakeAmount});
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemUpdatedSnackbar)));
      }
    }
  }

  void onDeleteIntake(IntakeEntity intake, TrackedDayEntity? trackedDayEntity) {
    _homeBloc.deleteIntakeItem(intake);
    _homeBloc.add(const LoadItemsEvent());
  }

  void _confirmDelete(BuildContext context, IntakeEntity intake) async {
    bool? delete = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (delete == true) {
      onDeleteIntake(intake, null);
    }
    setState(() {
      _isDragging = false;
    });
  }

  /// Show disclaimer dialog after build method
  void _showDisclaimerDialog(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dialogConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return const DisclaimerDialog();
          });
      if (dialogConfirmed != null) {
        _homeBloc.saveConfigData(dialogConfirmed);
        _homeBloc.add(const LoadItemsEvent());
      }
    });
  }

  /// Refresh page when day changes
  void _refreshPageOnDayChange() {
    if (!DateUtils.isSameDay(_homeBloc.currentDay, DateTime.now())) {
      _homeBloc.add(const LoadItemsEvent());
    }
  }


  /// Handle step count changed
  void onStepCount(StepCount event) {
    int steps = event.steps;
    DateTime timeStamp = event.timeStamp;
    setState(() {});
    debugPrint("steps added $steps");
    _homeBloc.updateTrackedDayFromStepsTaken(timeStamp, steps);
    _homeBloc.add(const LoadItemsEvent());
  }

  /// Handle status changed
  void onPedestrianStatusChanged(PedestrianStatus event) {
    String status = event.status;
    DateTime timeStamp = event.timeStamp;
    pedestrianStatus = status;
  }

  /// Handle the error
  void onPedestrianStatusError(error) {}

  /// Handle the error
  void onStepCountError(error) {}

  Future<void> initPlatformState() async {
    // Init streams
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    // Listen to streams and handle errors
    if(_stepCountStream != null && _pedestrianStatusStream != null) {
      _stepCountStream!.listen(onStepCount).onError(onStepCountError);

      _pedestrianStatusStream!
          .listen(onPedestrianStatusChanged)
          .onError(onPedestrianStatusError);
    }
  }

  Widget stepsCounterContainer(int totalStepStaken){
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Card(
            elevation: 1,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        // padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            // Icon(FontAwesomeIcons.stopwatch,
                            //     size: 24, color: Theme.of(context).colorScheme.onSurface),
                            // const SizedBox(width: 8.0),
                            Text(
                              "Steps Counter",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.stopwatch, size: 18),
                          const SizedBox(width: 10),
                          Text("$totalStepStaken steps", style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface)),
                          const Spacer(),
                          Icon(pedestrianStatus == "walking" ? FontAwesomeIcons.personWalking : pedestrianStatus == "stopped" ? FontAwesomeIcons.person : FontAwesomeIcons.circleStop, size: 18),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 100,
                            child: Text(["walking", "stopped"].contains(pedestrianStatus) ? "${pedestrianStatus}" : "No Activities", style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          SizedBox(
                            // width: 120,
                            child: Text("🔥", style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface)),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 120,
                            child: Text("${_homeBloc.getCalBurned(totalStepStaken).toStringAsFixed(2)} kcal", style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface)),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ]
                )
            )
        )
    );
  }
}
