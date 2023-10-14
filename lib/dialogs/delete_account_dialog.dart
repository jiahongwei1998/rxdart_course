import 'package:flutter/material.dart';
import 'package:rxdart_course/dialogs/generic_dialog.dart';

Future<bool> showDeleteAccountDialog({required BuildContext context}) =>
    showGenericDialog(
      context: context,
      title: 'Delete account',
      content: 'Are sure you want to delete your account?'
          'You cannot undo this operation!',
      optionBuilder: () => {'Cancel': false, 'Delete account': true},
    ).then((value) => value ?? false);
