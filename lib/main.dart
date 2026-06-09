import 'package:app_wearable/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'main_screens/welcome.dart';
import 'main_screens/login_screen.dart';
import 'main_screens/register_screen.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BentoHabit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Definición de las rutas de navegación
      initialRoute: '/',
      routes: {
        '/': (context) => const BentoScreen(),
        '/login_screen': (context) => const LoginScreen(),
        '/register_screen': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}