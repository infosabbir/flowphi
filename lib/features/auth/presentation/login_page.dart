import 'package:FlowPhi/features/auth/data/auth_repository.dart';
import 'package:FlowPhi/features/auth/presentation/forgot_password_page.dart';
import 'package:FlowPhi/features/auth/presentation/register_page.dart';
import 'package:FlowPhi/features/auth/presentation/widgets/auth_header.dart';
import 'package:FlowPhi/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:FlowPhi/core/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          padding: const EdgeInsets.all(24),
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
                      controller: _passwordController,

                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // procced with login
                            try {
                              final authRepository = AuthRepository();

                              await authRepository.login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );

                              final user = FirebaseAuth.instance.currentUser;

                              if (user != null && !user.emailVerified) {
                                await FirebaseAuth.instance.signOut();

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please verify your email before logging in',
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Login successful'),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              String message = 'Login failed';

                              if (e.code == 'user-not-found') {
                                message = 'No user found for this email';
                              } else if (e.code == 'wrong-password') {
                                message = 'Incorrect password';
                              } else if (e.code == 'invalid-email') {
                                message = 'Invalid email address';
                              } else if (e.code == 'invalid-credential') {
                                message = 'Invalid email or password';
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
