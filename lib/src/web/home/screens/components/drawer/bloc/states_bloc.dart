abstract class DrawerState {}

class DrawerInitial extends DrawerState {}

class DrawerLoading extends DrawerState {}

class DrawerLoaded extends DrawerState {
  final bool isAdmin;
  DrawerLoaded(this.isAdmin);
}

class DrawerError extends DrawerState {
  final String message;

  DrawerError(this.message);
}
