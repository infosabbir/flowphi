import 'package:FlowPhi/features/auth/presentation/login_page.dart';
import 'package:FlowPhi/features/dashboard/presentation/dashboard_page.dart';
import 'package:FlowPhi/features/auth/presentation/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authGate = ref.watch(authStateProvider);

    return authGate.when(
      data: (user) {
        if (user == null) {
          return const LoginPage();
        }
        return const DashboardPage();
      },
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Something went wrong: $error'))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
