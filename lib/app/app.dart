import 'package:flow_phi/core/theme/app_theme.dart';
import 'package:flow_phi/features/auth/presentation/auth_gate.dart';
import 'package:flutter/material.dart';

class FlowPhiApp extends StatelessWidget {
  const FlowPhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowPhi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
