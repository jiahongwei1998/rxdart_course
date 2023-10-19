import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart_course/blocs/auth_bloc/auth_bloc.dart';
import 'package:rxdart_course/blocs/auth_bloc/auth_error.dart';
import 'package:rxdart_course/blocs/contacts_bloc.dart';
import 'package:rxdart_course/blocs/views_bloc/current_view.dart';
import 'package:rxdart_course/blocs/views_bloc/views_bloc.dart';
import 'package:rxdart_course/models/contact.dart';

@immutable
class AppBloc {
  final AuthBloc _authBloc;
  final ViewsBloc _viewsBloc;
  final ContactsBloc _contactsBloc;

  final Stream<CurrentView> currentView;
  final Stream<bool> isLoading;
  final Stream<AuthError?> authError;
  final StreamSubscription<String?> _userIdChanges;

  const AppBloc._({
    required AuthBloc authBloc,
    required ViewsBloc viewsBloc,
    required ContactsBloc contactsBloc,
    required this.currentView,
    required this.isLoading,
    required this.authError,
    required StreamSubscription<String?> userIdChanges,
  })  : _authBloc = authBloc,
        _viewsBloc = viewsBloc,
        _contactsBloc = contactsBloc,
        _userIdChanges = userIdChanges;

  factory AppBloc() {
    final authBloc = AuthBloc();
    final viewsBloc = ViewsBloc();
    final contactsBloc = ContactsBloc();

    // Pass userid from auth block into contacts bloc
    final userIdChanges = authBloc.userId.listen((String? userId) {
      contactsBloc.userId.add(userId);
    });

    // Calculate the current view
    final Stream<CurrentView> currentViewBasedOnAuthStatus = authBloc.authStatus
        .map<CurrentView>((authStatus) => authStatus is AuthStatusLoggedIn
            ? CurrentView.contactList
            : CurrentView.login);

    final Stream<CurrentView> currentView = Rx.merge([
      currentViewBasedOnAuthStatus,
      viewsBloc.currentView,
    ]);

    final Stream<bool> isLoading = Rx.merge([
      authBloc.isLoading,
    ]);

    return AppBloc._(
      authBloc: authBloc,
      viewsBloc: viewsBloc,
      contactsBloc: contactsBloc,
      currentView: currentView,
      isLoading: isLoading.asBroadcastStream(),
      authError: authBloc.authError,
      userIdChanges: userIdChanges,
    );
  }

  void deleteContact(Contact contact) {
    _contactsBloc.deleteContact.add(contact);
  }

  void createContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) {
    _contactsBloc.createContact.add(Contact.withoutId(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    ));
  }

  void logout() {
    _authBloc.logout.add(null);
  }

  Stream<Iterable<Contact>> get contacts => _contactsBloc.contacts;

  void register(String email, String password) {
    _authBloc.register.add(RegisterCommand(
      email: email,
      password: password,
    ));
  }

  void login(String email, String password) {
    _authBloc.login.add(LoginCommand(
      email: email,
      password: password,
    ));
  }

  void goToContactListView() =>
      _viewsBloc.goToView.add(CurrentView.contactList);

  void goToCreateContactView() =>
      _viewsBloc.goToView.add(CurrentView.createContact);

  void goToRegisterView() => _viewsBloc.goToView.add(CurrentView.register);

  void goToLoginVIew() => _viewsBloc.goToView.add(CurrentView.login);

  void dispose() {
    _authBloc.dispose();
    _viewsBloc.dispose();
    _contactsBloc.dispose();
    _userIdChanges.cancel();
  }
}
