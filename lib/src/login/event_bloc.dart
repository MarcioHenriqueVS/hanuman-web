abstract class LoginEvent {}

class PerformLoginEvent extends LoginEvent {
  final String email;
  final String password;
  PerformLoginEvent(this.email, this.password);
}