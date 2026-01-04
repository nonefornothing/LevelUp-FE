abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashCompleted extends SplashState {}

class SplashRouteDecision extends SplashState {
  final String route;
  SplashRouteDecision(this.route);
}