import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final styl = Theme.of(context).textTheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundImage: AssetImage('assets/icon/icon.png'),
        ),
        SizedBox(height: 20),
        Text(title, style: styl.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: styl.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}
