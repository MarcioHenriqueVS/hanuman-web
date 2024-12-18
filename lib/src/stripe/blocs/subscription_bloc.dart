import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class SubscriptionEvent {}

class LoadSubscription extends SubscriptionEvent {
  final String uid;
  LoadSubscription(this.uid);
}

// States
abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final Map<String, dynamic> subscription;
  SubscriptionLoaded(this.subscription);
}

class SubscriptionError extends SubscriptionState {
  final String message;
  SubscriptionError(this.message);
}

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final FirebaseFirestore _firestore;

  SubscriptionBloc(this._firestore) : super(SubscriptionInitial()) {
    on<LoadSubscription>(_onLoadSubscription);
  }

  void _onLoadSubscription(
      LoadSubscription event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      await for (var snapshot in _firestore
          .collection('subscriptions')
          .doc(event.uid)
          .snapshots()) {
        if (snapshot.exists) {
          emit(SubscriptionLoaded(snapshot.data() as Map<String, dynamic>));
        } else {
          emit(SubscriptionLoaded({}));
        }
      }
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }
}
