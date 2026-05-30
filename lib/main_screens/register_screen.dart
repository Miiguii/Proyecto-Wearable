import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: Column(
                children: [
                  const Text("Crear Cuenta", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  _input("Nombre completo", Icons.person_outline),
                  const SizedBox(height: 15),
                  _input("Correo electrónico", Icons.email_outlined),
                  const SizedBox(height: 15),
                  _input("Contraseña", Icons.lock_outline, isPass: true),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB7A2), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: const Text("Registrarme", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFC1EAD1), borderRadius: BorderRadius.circular(40)),
              child: const Text("Al registrarte, aceptas nuestros términos.", textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, IconData icon, {bool isPass = false}) {
    return TextFormField(
      obscureText: isPass,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: label,
        filled: true,
        fillColor: const Color(0xFFF0F2F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    );
  }
}