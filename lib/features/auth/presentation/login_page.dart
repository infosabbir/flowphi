import 'package:FlowPhi/features/auth/presentation/register_page.dart';
import 'package:FlowPhi/features/dashboard/presentation/widgets/auth_header.dart';
import 'package:FlowPhi/features/dashboard/presentation/widgets/auth_text_field.dart';
import 'package:FlowPhi/features/dashboard/presentation/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                    title: 'Welcome Back',
                    subtitle:
                        'Login to continue managing your personal finance',
                  ),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Don't have an account?", style: styl.bodyMedium),
                        const SizedBox(width: 8),
                        Text('Register', selectionColor: Colors.green),
                      ],
                    ),
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
