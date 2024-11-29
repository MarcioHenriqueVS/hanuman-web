sealed class AttsHomeState {}

final class AttsHomeInitial extends AttsHomeState {}

final class AttsHomeLoading extends AttsHomeState {}

final class AttsHomeLoaded extends AttsHomeState {
  final List<Map<String, dynamic>> atts;

  AttsHomeLoaded(this.atts);
}

final class AttsHomeError extends AttsHomeState {
  final String message;

  AttsHomeError(this.message);
}

final class AttsHomeEmpty extends AttsHomeState {}
