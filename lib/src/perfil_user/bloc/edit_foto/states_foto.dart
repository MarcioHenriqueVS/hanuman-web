abstract class PickImageState {}

class PickImageInitial extends PickImageState {}

class PickImageLoading extends PickImageState {}

class PickImageLoaded extends PickImageState {
  String? foto;
  PickImageLoaded(this.foto);
}

class PickImageError extends PickImageState {
  final String message;

  PickImageError(this.message);
}