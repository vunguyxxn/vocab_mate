import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_gate.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class VocabMateApp extends StatelessWidget {
  const VocabMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'VocabMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}