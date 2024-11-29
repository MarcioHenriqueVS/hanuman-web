class GetPastasState {}

final class GetPastasInitial extends GetPastasState {}

final class GetPastasLoading extends GetPastasState {}

final class GetPastasLoaded extends GetPastasState {
  List<Map<String, dynamic>> pastasIds;

  GetPastasLoaded(this.pastasIds);
}

final class GetPastasError extends GetPastasState {
  String message;

  GetPastasError(this.message);
}
