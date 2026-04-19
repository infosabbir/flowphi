import 'package:FlowPhi/core/theme/app_theme.dart';
import 'package:FlowPhi/features/auth/presentation/login_page.dart';
import 'package:flutter/material.dart';

class FlowPhiApp extends StatelessWidget {
  const FlowPhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowPhi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
