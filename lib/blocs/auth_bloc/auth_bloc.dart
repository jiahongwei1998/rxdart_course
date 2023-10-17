import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart_course/blocs/auth_bloc/auth_error.dart';

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
  Stream<E> setLoadingTo(
    bool isLoading, {
    required Sink<bool> onSink,
  }) =>
      doOnEach(
        (notification) => onSink.add(isLoading),
      );
}

@immutable
class AuthBloc {
  // Read only properties
  final Stream<AuthStatus> authStatus;
  final Stream<AuthError?> authError;
  final Stream<bool> isLoading;
  final Stream<String?> userId;
  // Write only properties
  final Sink<LoginCommand> login;
  final Sink<RegisterCommand> register;
  final Sink<void> logout;

  const AuthBloc._({
    required this.authStatus,
    required this.authError,
    required this.isLoading,
    required this.userId,
    required this.login,
    required this.register,
    required this.logout,
  });

  factory AuthBloc() {
    final isLoading = BehaviorSubject<bool>();
    final Stream<AuthStatus> authStatus = FirebaseAuth.instance
        .authStateChanges()
        .map((user) => user != null
            ? const AuthStatusLoggedIn()
            : const AuthStatusLoggedOut());

    final Stream<String?> userId = FirebaseAuth.instance
        .authStateChanges()
        .map((user) => user?.uid)
        .startWith(FirebaseAuth.instance.currentUser?.uid);

    final login = BehaviorSubject<LoginCommand>();
    final Stream<AuthError?> loginError = login
        .setLoadingTo(true, onSink: isLoading)
        .asyncMap<AuthError?>((loginCommand) async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: loginCommand.email,
          password: loginCommand.password,
        );
        return null;
      } on FirebaseAuthException catch (e) {
        return AuthError.from(e);
      } catch (_) {
        return const AuthErrorUnknown();
      }
    }).setLoadingTo(false, onSink: isLoading);

    final register = BehaviorSubject<RegisterCommand>();
    final Stream<AuthError?> registerError = register
        .setLoadingTo(true, onSink: isLoading)
        .asyncMap<AuthError?>((registerCommand) async {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: registerCommand.email,
          password: registerCommand.password,
        );
        return null;
      } on FirebaseAuthException catch (e) {
        return AuthError.from(e);
      } catch (_) {
        return const AuthErrorUnknown();
      }
    }).setLoadingTo(false, onSink: isLoading);

    final logout = BehaviorSubject<void>();
    final Stream<AuthError?> logoutError = logout
        .setLoadingTo(true, onSink: isLoading)
        .asyncMap<AuthError?>((_) async {
      try {
        await FirebaseAuth.instance.signOut();
        return null;
      } on FirebaseAuthException catch (e) {
        return AuthError.from(e);
      } catch (_) {
        return const AuthErrorUnknown();
      }
    }).setLoadingTo(false, onSink: isLoading);

    // authError = loginError + registerError + logoutError
    final Stream<AuthError?> authError = Rx.merge([
      loginError,
      registerError,
      logoutError,
    ]);

    return AuthBloc._(
      authStatus: authStatus,
      authError: authError,
      isLoading: isLoading,
      userId: userId,
      login: login,
      register: register,
      logout: logout,
    );
  }
}
