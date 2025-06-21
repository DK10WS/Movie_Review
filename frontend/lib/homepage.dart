import 'package:flutter/material.dart';
import 'auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Future<void> loadUser() async {
    final data = await AuthService.whoami(context);
    if (!mounted) return;

    if (data != null) {
      setState(() {
        username = data['username'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      showError("Failed to load user data. Please login again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome ${username ?? ''}')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text('Hello, $username!', style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
