import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rxdart_course/loading/helpers/if_debugging.dart';
import 'package:rxdart_course/type_definitions.dart';

class RegisterView extends HookWidget {
  final RegisterFunction register;
  final VoidCallback goToLoginView;

  const RegisterView({
    super.key,
    required this.register,
    required this.goToLoginView,
  });

  @override
  Widget build(BuildContext context) {
    final emailController =
        useTextEditingController(text: 'hjia@lucent.com'.ifDebugging);
    final passwordController =
        useTextEditingController(text: 'hesong'.ifDebugging);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration:
                  const InputDecoration(hintText: 'Enter your email here...'),
              keyboardType: TextInputType.emailAddress,
              keyboardAppearance: Brightness.dark,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                  hintText: 'Enter your password here...'),
              obscureText: true,
              // obscuringCharacter: '🔘',
              keyboardAppearance: Brightness.dark,
            ),
            TextButton(
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;
                register(email, password);
              },
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: goToLoginView,
              child: const Text('Already registered et? Login here!'),
            ),
          ],
        ),
      ),
    );
  }
}
