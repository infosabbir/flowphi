import 'package:FlowPhi/features/auth/presentation/register_page.dart';
import 'package:FlowPhi/features/auth/presentation/widgets/auth_header.dart';
import 'package:FlowPhi/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:FlowPhi/core/custom_appbar.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styl = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CustomAppbar(),
      body: SafeArea(
        child: Padding(
          padding:const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const AuthHeader(
                      title: 'Welcome Back',
                      subtitle:
                          'Login to continue managing your personal finance',
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      controller: _passwordController,

                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // procced with login
                          }
                        },
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterPage()),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: styl.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Register',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
