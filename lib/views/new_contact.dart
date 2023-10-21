import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rxdart_course/loading/helpers/if_debugging.dart';
import 'package:rxdart_course/type_definitions.dart';

class NewContactView extends HookWidget {
  final CreateContactCallback createContact;
  final GoBackCallback goBack;

  const NewContactView(
      {required this.createContact, required this.goBack, super.key});

  @override
  Widget build(BuildContext context) {
    final firstNameController = useTextEditingController(
      text: 'David'.ifDebugging,
    );
    final lastNameController = useTextEditingController(
      text: 'Jia'.ifDebugging,
    );
    final phoneNumberController = useTextEditingController(
      text: '+461234567890'.ifDebugging,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a new contact'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: goBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(hintText: 'First name...'),
              keyboardType: TextInputType.name,
              keyboardAppearance: Brightness.dark,
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(hintText: 'Last name...'),
              keyboardType: TextInputType.name,
              keyboardAppearance: Brightness.dark,
            ),
            TextField(
              controller: phoneNumberController,
              decoration: const InputDecoration(hintText: 'Phone number...'),
              keyboardType: TextInputType.phone,
              keyboardAppearance: Brightness.dark,
            ),
            TextButton(
              onPressed: () {
                final firstName = firstNameController.text;
                final lastName = lastNameController.text;
                final phoneNumber = phoneNumberController.text;
                createContact(firstName, lastName, phoneNumber);
                goBack();
              },
              child: const Text('Save contact'),
            ),
          ],
        ),
      ),
    );
  }
}
