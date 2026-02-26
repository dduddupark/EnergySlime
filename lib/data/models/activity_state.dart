import 'activity_model.dart';

class ActivityState {
  final ActivityModel? todayActivity;
  final bool isLoading;
  final bool hasHealthData;
  final bool isFetching;

  ActivityState({
    this.todayActivity,
    this.isLoading = true,
    this.hasHealthData = false,
    this.isFetching = false,
  });

  ActivityState copyWith({
    ActivityModel? todayActivity,
    bool? isLoading,
    bool? hasHealthData,
    bool? isFetching,
  }) {
    return ActivityState(
      todayActivity: todayActivity ?? this.todayActivity,
      isLoading: isLoading ?? this.isLoading,
      hasHealthData: hasHealthData ?? this.hasHealthData,
      isFetching: isFetching ?? this.isFetching,
    );
  }
}
