class GetPastasPersonalState {}

final class GetPastasPersonalInitial extends GetPastasPersonalState {}

final class GetPastasPersonalLoading extends GetPastasPersonalState {}

final class GetPastasPersonalLoaded extends GetPastasPersonalState {
  List<Map<String, dynamic>> pastasIds;

  GetPastasPersonalLoaded(this.pastasIds);
}

final class GetPastasPersonalError extends GetPastasPersonalState {
  String message;

  GetPastasPersonalError(this.message);
}
