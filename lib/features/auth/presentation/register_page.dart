import 'package:FlowPhi/features/auth/data/auth_repository.dart';
import 'package:FlowPhi/features/auth/presentation/login_page.dart';
import 'package:FlowPhi/features/auth/presentation/widgets/auth_header.dart';
import 'package:FlowPhi/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:FlowPhi/core/custom_appbar.dart';
import 'package:FlowPhi/features/dashboard/presentation/dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  final _fullnameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const AuthHeader(
                      title: 'Create Account',
                      subtitle:
                          'Register and start tracking your money smartly',
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      controller: _fullnameController,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your email address';
                        }
                        final email = value.trim();
                        final emailRegex = RegExp(
                          r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(email)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password';
                        }
                        final passwordRegex = RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
                        );
                        if (!passwordRegex.hasMatch(value)) {
                          return 'Use 8+ chars, upper, lower, number, special';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Confirm Password',
                      icon: Icons.lock_reset_outlined,
                      isPassword: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Password does not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // proceed with register
                            try {
                              final authRepository = AuthRepository();

                              await authRepository.register(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );

                              final user = FirebaseAuth.instance.currentUser;
                              await user?.sendEmailVerification();

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Registration successful. A verification link has been sent to your email',
                                  ),
                                ),
                              );

                              await Future.delayed(
                                const Duration(milliseconds: 800),
                              );

                              if (!context.mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              String message = 'Register failed';

                              if (e.code == 'email-already-in-use') {
                                message = 'This email is already in use';
                              } else if (e.code == 'weak-password') {
                                message = 'Password is too weak';
                              } else if (e.code == 'invalid-email') {
                                message = 'Invalid email address';
                              }

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            } catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        child: const Text('Register'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()),
                            );
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
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
