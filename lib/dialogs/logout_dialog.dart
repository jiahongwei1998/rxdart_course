import 'package:flutter/material.dart';
import 'package:rxdart_course/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog({required BuildContext context}) =>
    showGenericDialog(
      context: context,
      title: 'Log out',
      content: 'Are sure you want to logo ut?',
      optionBuilder: () => {'Cancel': false, 'Log out': true},
    ).then((value) => value ?? false);
