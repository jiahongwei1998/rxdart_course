import 'package:flutter/material.dart';
import 'package:rxdart_course/blocs/auth_bloc/auth_error.dart';
import 'package:rxdart_course/dialogs/generic_dialog.dart';

Future<void> showAuthError({
  required AuthError authError,
  required BuildContext context,
}) {
  return showGenericDialog(
    context: context,
    title: authError.dialogTitle,
    content: authError.diagText,
    optionBuilder: () => {
      'OK': true,
    },
  );
}
