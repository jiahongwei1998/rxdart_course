import 'package:flutter/material.dart';
import 'package:rxdart_course/dialogs/generic_dialog.dart';

Future<bool> showDeleteContactDialog({
  required BuildContext context,
}) =>
    showGenericDialog(
      context: context,
      title: 'Delete contact',
      content: 'Are you sure you want to delete this contact?'
          ' You cannot undo this operation!',
      optionBuilder: () => {'Cancel': false, 'Delete contact': true},
    ).then((value) => value ?? false);
