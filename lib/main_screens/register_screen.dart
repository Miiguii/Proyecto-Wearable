import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. LLAVE GLOBAL PARA CONTROLAR EL ESTADO DEL FORMULARIO
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar el texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 2. DATOS SIMULADOS (Correos que simulan ya estar registrados en el sistema)
  final List<String> _registeredEmailsSimulated = [
    'test@gmail.com',
    'yaretzi@gmail.com',
    'rubio@goalify.com'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 3. FUNCIÓN PARA PROCESAR EL REGISTRO CON LAS VALIDACIONES
  void _submitData() {
    // Si todas las validaciones locales pasan
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();

      // Validación con datos simulados: Verificar si el correo ya existe
      if (_registeredEmailsSimulated.contains(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este correo electrónico ya está registrado.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Si el correo está libre, simula éxito y avanza
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Cuenta creada con éxito! Bienvenido, ${_nameController.text}'),
            backgroundColor: const Color(0xFF2B7A4B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Redirige al Dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Form(
          key: _formKey, // 4. ENVOLVEMOS NUESTRA COLUMNA EN EL FORM
          child: Column(
            children: [
              // --- LOGOTIPO DE LA APP ---
              Center(
                child: Image.asset(
                  'assets/imagenes/Logo2.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),

              // --- CONTENEDOR BENTO (REGISTRO) ---
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Crear Cuenta",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                    ),
                    const SizedBox(height: 25),

                    // Campo Nombre Completo
                    _buildInputField(
                      controller: _nameController,
                      label: "Nombre completo",
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, ingresa tu nombre completo';
                        }
                        if (value.trim().length < 3) {
                          return 'El nombre debe tener al menos 3 letras';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo Correo Electrónico
                    _buildInputField(
                      controller: _emailController,
                      label: "Correo electrónico",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, ingresa un correo electrónico';
                        }
                        // RegExp básico para validar formato de email
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Ingresa un formato de correo válido (ej@dominio.com)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo Contraseña
                    _buildInputField(
                      controller: _passwordController,
                      label: "Contraseña",
                      icon: Icons.lock_outline,
                      isPass: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa una contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    // Botón Registrarme
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _submitData, // Ejecuta las validaciones al presionar
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB7A2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          "Registrarme",
                          style: TextStyle(color: Color(0xFF0D253F), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // --- BANNER DE TÉRMINOS Y CONDICIONES ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFC1EAD1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Text(
                  "Al registrarte, aceptas nuestros términos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF0D253F), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. MÉTODOS REFACTORIZADO PARA CONSTRUIR INPUTS CON SOPORTE DE VALIDACIÓN
  Widget _buildInputField({
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
      validator: validator, // Agrega la lógica de validación individual
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: label,
        filled: true,
        fillColor: const Color(0xFFF0F2F5),
        errorStyle: const TextStyle(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        // Esto ayuda a resaltar el campo con error sutilmente
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    );
  }
}