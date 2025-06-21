import 'package:flutter/material.dart';
import 'auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final fullnameController = TextEditingController();
  final passwordController = TextEditingController();

  bool emailVerified = false;
  bool isLoading = false;

  void showMessage(String message, {Color color = Colors.red}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Future<void> sendOtp() async {
    setState(() => isLoading = true);
    final success = await AuthService.sendOTP(emailController.text, context);
    setState(() => isLoading = false);

    if (success) {
      setState(() => emailVerified = true);
      showMessage(
        "Check your email for the verification link.",
        color: Colors.green,
      );
    }
    // Errors handled via handleApiError
  }

  Future<void> registerUser() async {
    setState(() => isLoading = true);

    final success = await AuthService.registerUser(
      usernameController.text,
      fullnameController.text,
      emailController.text,
      passwordController.text,
      context,
    );

    setState(() => isLoading = false);

    if (success) {
      showMessage(
        "Registration successful. Please login.",
        color: Colors.green,
      );
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Widget buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : sendOtp,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Send Verification Link'),
        ),
      ],
    );
  }

  Widget buildRegisterStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        TextField(
          controller: fullnameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : registerUser,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Register'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: emailVerified ? buildRegisterStep() : buildEmailStep(),
      ),
    );
  }
}
