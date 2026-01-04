abstract class AuthEvent {}

class AuthAppStarted extends AuthEvent {}

class AuthLoginWithEmail extends AuthEvent {
  final String email;
  final String password;
  AuthLoginWithEmail(this.email, this.password);
}

class AuthRegisterWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String username;
  AuthRegisterWithEmail(this.email, this.password, this.username);
}

class AuthLogout extends AuthEvent {}


