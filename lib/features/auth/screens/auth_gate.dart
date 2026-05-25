import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../home/screens/home_screen.dart';
import '../../notification/services/fcm_service.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _fcmInitialized = false;

  Future<void> _initializeFcmOnce() async {
    if (_fcmInitialized) return;

    _fcmInitialized = true;

    try {
      await FcmService.initialize();
    } catch (e) {
      debugPrint('FCM initialize error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final currentSession = Supabase.instance.client.auth.currentSession;
        final session = snapshot.data?.session ?? currentSession;

        if (snapshot.connectionState == ConnectionState.waiting &&
            currentSession == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (session != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeFcmOnce();
          });

          return const HomeScreen();
        }

        _fcmInitialized = false;
        return const LoginScreen();
      },
    );
  }
}