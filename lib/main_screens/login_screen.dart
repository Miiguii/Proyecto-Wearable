import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. LLAVE GLOBAL PARA EL FORMULARIO
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 2. CREDENCIALES SIMULADAS PARA EL LOGIN
  final String _validEmailSimulated = 'yaretzi@gmail.com';
  final String _validPasswordSimulated = '123456';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 3. FUNCIÓN PARA PROCESAR EL INICIO DE SESIÓN
  void _login() {
    // Primero valida las reglas locales (formato e inputs vacíos)
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      // Validación simulada de "Base de Datos"
      if (email == _validEmailSimulated &&
          password == _validPasswordSimulated) {
        // Login Exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Inicio de sesión exitoso! Bienvenido de vuelta.'),
            backgroundColor: Color(0xFF2B7A4B), // Verde pastel éxito
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Redirige al Dashboard eliminando el historial para que no pueda regresar al login con el botón de atrás
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Credenciales incorrectas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo electrónico o contraseña incorrectos.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ss = ScreenSize.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ss.maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ss.gap(25),
              vertical: ss.gap(10),
            ),
            child: Form(
              key: _formKey, // 4. ENVOLVEMOS LOS CAMPOS EN EL FORM
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/imagenes/Logo2.png',
                      height: ss.gap(120),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: ss.gap(30)),

                  // --- CONTENEDOR---
                  Container(
                    width: double.infinity,
                    padding: ss.paddingAll(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "¡Bienvenido!",
                          style: TextStyle(
                            fontSize: ss.font(28),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D253F),
                          ),
                        ),
                        SizedBox(height: ss.gap(30)),

                        // Input Correo Electrónico
                        _buildTextField(
                          ss: ss,
                          controller: _emailController,
                          label: "Correo electrónico",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, ingresa tu correo';
                            }
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Ingresa un correo válido (ej@dominio.com)';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ss.gap(15)),

                        // Input Contraseña
                        _buildTextField(
                          ss: ss,
                          controller: _passwordController,
                          label: "Contraseña",
                          icon: Icons.lock_outline,
                          isPass: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ss.gap(30)),

                        // Botón Entrar
                        SizedBox(
                          width: double.infinity,
                          height: ss.gap(55),
                          child: ElevatedButton(
                            onPressed:
                                _login, // Llama a la función con validaciones
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFE382),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Entrar",
                              style: TextStyle(
                                color: const Color(0xFF0D253F),
                                fontWeight: FontWeight.bold,
                                fontSize: ss.font(16),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // 5. CONSTRUCTOR DE INPUTS ADAPTADO PARA VALIDACIONES
  Widget _buildTextField({
    required ScreenSize ss,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    bool isPass = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPass,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: ss.font(14)),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey, size: ss.icon(22)),
        hintText: label,
        hintStyle: TextStyle(fontSize: ss.font(14)),
        filled: true,
        fillColor: const Color(0xFFF0F2F5),
        errorStyle: const TextStyle(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
