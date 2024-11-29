abstract class SelectVideoState {}

class SelectVideoInitial extends SelectVideoState {}

class SelectVideoLoading extends SelectVideoState {}

class SelectVideoLoaded extends SelectVideoState {
  final String video;
  SelectVideoLoaded(this.video);
}

class SelectVideoError extends SelectVideoState {
  final String message;

  SelectVideoError(this.message);
}