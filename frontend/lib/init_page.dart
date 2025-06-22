import 'package:flutter/material.dart';
import 'auth.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await AuthService.getToken();

    if (token != null) {
      final user = await AuthService.whoami(context, silent: true);

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
        return;
      } else {
        await AuthService.logout();
      }
    }

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
