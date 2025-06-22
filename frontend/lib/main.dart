import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'homepage.dart';
import 'theme.dart';
import 'init_page.dart'; // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DK's List",
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/init', // 👈 Start with init page
      routes: {
        '/init': (context) => const InitPage(), // 👈 Added InitPage
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
