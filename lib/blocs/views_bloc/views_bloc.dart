import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart_course/blocs/views_bloc/current_view.dart';

@immutable
class ViewsBloc {
  final Sink<CurrentView> goToView;
  final Stream<CurrentView> currentView;

  const ViewsBloc._({
    required this.goToView,
    required this.currentView,
  });

  factory ViewsBloc() {
    final goToViewSubject = BehaviorSubject<CurrentView>();

    return ViewsBloc._(
      goToView: goToViewSubject,
      currentView: goToViewSubject.startWith(
        CurrentView.login,
      ),
    );
  }

  void dispose() {
    goToView.close();
  }
}
