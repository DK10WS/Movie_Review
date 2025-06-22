import 'dart:ui';
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

    final response = await AuthService.sendOTPWithResponse(
      emailController.text.trim().toLowerCase(),
    );

    setState(() => isLoading = false);

    if (response['success'] || response['code'] == 409) {
      setState(() => emailVerified = true);
      showMessage(
        response['code'] == 409
            ? "Email already verified. Proceed to register."
            : "Check your email for the verification link.",
        color: Colors.green,
      );
    } else if (response['code'] == 408) {
      showMessage(
        "Email already has an account. Redirecting to login...",
        color: Colors.orange,
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
      });
    } else {
      showMessage(response['message'] ?? 'An unexpected error occurred');
    }
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
        _buildTextField(emailController, 'Email'),
        const SizedBox(height: 20),
        _buildButton("Send Verification Link", sendOtp),
      ],
    );
  }

  Widget buildRegisterStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(usernameController, 'Username'),
        _buildTextField(fullnameController, 'Full Name'),
        _buildTextField(passwordController, 'Password', obscure: true),
        const SizedBox(height: 20),
        _buildButton("Register", registerUser),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.transparent,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("DK's List"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        emailVerified ? "Register" : "Signup",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      emailVerified ? buildRegisterStep() : buildEmailStep(),
                      if (emailVerified) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/'),
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
