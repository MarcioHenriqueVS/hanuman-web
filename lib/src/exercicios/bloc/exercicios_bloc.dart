import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/exercicio_model.dart';
import '../services/exercicios_services.dart';
import 'event.dart';
import 'state.dart';

class ExercicioBloc extends Bloc<ExercicioEvent, ExercicioState> {
  final ExerciciosServices exerciciosServices;

  ExercicioBloc(this.exerciciosServices) : super(ExercicioInitial()) {
    on<LoadExercicios>(_loadExercicios);
  }

  Future<void> _loadExercicios(
      LoadExercicios event, Emitter<ExercicioState> emit) async {
    emit(ExercicioLoading());
    try {
      List<Exercicio>? exercicios = await exerciciosServices.getAllExercicios();
      if (exercicios != null) {
        emit(ExercicioLoaded(exercicios));
      } else {
        emit(ExercicioError('Erro ao carregar exercícios.'));
      }
    } catch (e) {
      emit(ExercicioError(e.toString()));
    }
  }
}
