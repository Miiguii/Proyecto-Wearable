import 'package:flutter/material.dart';


class BentoScreen extends StatelessWidget {
  const BentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String rutaLogo = 'assets/imagenes/Logo2.png';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        rutaLogo,
                        height: 120,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.fastfood, size: 80, color: Color.fromARGB(255, 0, 81, 255)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Organiza tu vida,\npieza por pieza",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC1EAD1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("GOALIFY", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
                      SizedBox(height: 10),
                      Text("¡Hola! Estás a un paso de construir\ntus mejores hábitos", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFF2D3436))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBtn(context, "Crear una cuenta", const Color(0xFFFFB7A2), '/register_screen'),
                      const SizedBox(height: 12),
                      _buildBtn(context, "Iniciar sesión", const Color(0xFFF0F2F5), '/login_screen'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text("Tu compañero para construir mejores hábitos", style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(BuildContext context, String text, Color color, String route) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}