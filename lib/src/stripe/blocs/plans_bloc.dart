import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/plan_model.dart';
import '../stripe_test_services.dart';

// Events
abstract class PlansEvent {}

class LoadPlans extends PlansEvent {}

// States
abstract class PlansState {}

class PlansInitial extends PlansState {}

class PlansLoading extends PlansState {}

class PlansLoaded extends PlansState {
  final List<PlanModel> plans;
  PlansLoaded(this.plans);
}

class PlansError extends PlansState {
  final String message;
  PlansError(this.message);
}

class PlansBloc extends Bloc<PlansEvent, PlansState> {
  final StripeTestServices _services;

  PlansBloc(this._services) : super(PlansInitial()) {
    on<LoadPlans>(_onLoadPlans);
  }

  Future<void> _onLoadPlans(LoadPlans event, Emitter<PlansState> emit) async {
    emit(PlansLoading());
    try {
      final plans = await _services.buscarPlanos();
      emit(PlansLoaded(plans));
    } catch (e) {
      emit(PlansError(e.toString()));
    }
  }
}
