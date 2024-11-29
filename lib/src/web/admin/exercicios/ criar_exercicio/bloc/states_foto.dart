abstract class SelectFotoState {}

class SelectFotoInitial extends SelectFotoState {}

class SelectFotoLoading extends SelectFotoState {}

class SelectFotoLoaded extends SelectFotoState {
  final String foto;
  SelectFotoLoaded(this.foto);
}

class SelectFotoError extends SelectFotoState {
  final String message;

  SelectFotoError(this.message);
}
