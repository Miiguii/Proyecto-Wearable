import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: Column(
                children: [
                  const Text("¡Bienvenido!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  _buildTextField("Correo electrónico", Icons.email_outlined),
                  const SizedBox(height: 15),
                  _buildTextField("Contraseña", Icons.lock_outline, isPass: true),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFE382), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: const Text("Entrar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPass = false}) {
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