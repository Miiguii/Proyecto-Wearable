import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

class BentoScreen extends StatelessWidget {
  const BentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String rutaLogo = 'assets/imagenes/Logo2.png';
    final ss = ScreenSize.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ss.maxContentWidth),
            // SingleChildScrollView: si el contenido no entra en pantallas
            // chicas o con poco alto disponible, hace scroll en vez de
            // desbordarse (evita el "BOTTOM OVERFLOWED BY X PIXELS").
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ss.gap(25),
                vertical: ss.gap(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: ss.paddingAll(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          rutaLogo,
                          height: ss.gap(100),
                          errorBuilder:
                              (context, error, stackTrace) => Icon(
                                Icons.fastfood,
                                size: ss.icon(80),
                                color: const Color.fromARGB(255, 0, 81, 255),
                              ),
                        ),
                        SizedBox(height: ss.gap(16)),
                        Text(
                          "Organiza tu vida,\npieza por pieza",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ss.font(22),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ss.gap(15)),
                  Container(
                    width: double.infinity,
                    padding: ss.paddingAll(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1EAD1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "GOALIFY",
                          style: TextStyle(
                            fontSize: ss.font(28),
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0D253F),
                          ),
                        ),
                        SizedBox(height: ss.gap(10)),
                        Text(
                          "¡Hola! Estás a un paso de construir\ntus mejores hábitos",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ss.font(15),
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ss.gap(15)),
                  Container(
                    width: double.infinity,
                    padding: ss.paddingAll(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBtn(
                          context,
                          ss,
                          "Crear una cuenta",
                          const Color(0xFFFFB7A2),
                          '/register_screen',
                        ),
                        SizedBox(height: ss.gap(12)),
                        _buildBtn(
                          context,
                          ss,
                          "Iniciar sesión",
                          const Color(0xFFF0F2F5),
                          '/login_screen',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ss.gap(24)),
                  Text(
                    "Tu compañero para construir mejores hábitos",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: ss.font(13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(
    BuildContext context,
    ScreenSize ss,
    String text,
    Color color,
    String route,
  ) {
    return SizedBox(
      width: double.infinity,
      height: ss.gap(55),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: ss.font(15),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
