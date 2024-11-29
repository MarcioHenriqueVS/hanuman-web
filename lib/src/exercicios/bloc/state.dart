import '../model/exercicio_model.dart';

abstract class ExercicioState {}

class ExercicioInitial extends ExercicioState {}

class ExercicioLoading extends ExercicioState {}

class ExercicioLoaded extends ExercicioState {
  final List<Exercicio> exercicios;
  
  ExercicioLoaded(this.exercicios);
}

class ExercicioError extends ExercicioState {
  final String message;
  
  ExercicioError(this.message);
}
