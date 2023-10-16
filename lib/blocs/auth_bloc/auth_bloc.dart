import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

@immutable
abstract class AuthStatus {
  const AuthStatus();
}

@immutable
class AuthStatusLoggedOut implements AuthStatus {
  const AuthStatusLoggedOut();
}

@immutable
class AuthStatusLoggedIn implements AuthStatus {
  const AuthStatusLoggedIn();
}

@immutable
abstract class AuthCommand {
  final String email;
  final String password;

  const AuthCommand({
    required this.email,
    required this.password,
  });
}

@immutable
class LoginCommand extends AuthCommand {
  const LoginCommand({
    required super.email,
    required super.password,
  });
}

@immutable
class RegisterCommand extends AuthCommand {
  const RegisterCommand({
    required super.email,
    required super.password,
  });
}

extension Loading<E> on Stream<E> {
  Stream<E> setLoading(
    bool isLoading, {
    required Sink<bool> onSink,
  }) =>
      doOnEach(
        (notification) => onSink.add(isLoading),
      );
}
