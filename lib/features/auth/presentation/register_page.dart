import 'package:FlowPhi/features/dashboard/presentation/widgets/auth_header.dart';
import 'package:FlowPhi/features/dashboard/presentation/widgets/auth_text_field.dart';
import 'package:FlowPhi/features/dashboard/presentation/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final styl = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppbar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const AuthHeader(
                    title: 'Create Account',
                    subtitle: 'Register and start tracking your money smartly',
                  ),
                  const SizedBox(height: 32),
                  const AuthTextField(
                    label: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  const AuthTextField(
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  const AuthTextField(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  const AuthTextField(
                    label: 'Confirm Password',
                    icon: Icons.lock_reset_outlined,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Register'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'By continuing, you agree to our terms and privacy policy.',
                    style: styl.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
