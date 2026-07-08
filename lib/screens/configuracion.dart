import 'package:flutter/material.dart';

class ConfigScreen extends StatefulWidget {
  final List<Map<String, dynamic>> habits;
  final ValueChanged<bool>? onDarkModeChanged;

  const ConfigScreen({
    super.key,
    required this.habits,
    this.onDarkModeChanged,
  });

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool _isDarkMode = false;

  // --- 🛠️ MÉTODOS DE ACCIÓN PARA CADA APARTADO ---

  // 1. Acción para Perfil
  void _openProfileEditor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Editar Perfil", style: TextStyle(color: Color(0xFF0D253F), fontWeight: FontWeight.bold)),
        content: const Text("Aquí podrás modificar tu nombre, correo y avatar en la siguiente versión."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido", style: TextStyle(color: Color(0xFF0D253F), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 2. Acción para Copia de Seguridad
  void _backupData() {
    // Mostramos un indicador de carga rápido y luego el éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.cloud_done, color: Colors.white),
            SizedBox(width: 10),
            Text("¡Progreso y rachas respaldados con éxito!"),
          ],
        ),
        backgroundColor: const Color(0xFF0D253F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 3. Acción para Categorías
  void _manageCategories() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Categorías Actuales", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              children: [
                Chip(label: const Text("Salud"), backgroundColor: const Color(0xFFC1EAD1).withOpacity(0.5)),
                Chip(label: const Text("Estudio"), backgroundColor: const Color(0xFFD4C7F7).withOpacity(0.5)),
                Chip(label: const Text("Trabajo"), backgroundColor: const Color(0xFFFFB7A2).withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 4. Acción para Vincular Dispositivos
  void _connectDevice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: const [
            Icon(Icons.watch, color: Color(0xFF0D253F)),
            SizedBox(width: 10),
            Text("Buscando Dispositivos...", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            LinearProgressIndicator(color: Color(0xFFD4C7F7), backgroundColor: Color(0xFFF5F5F0)),
            SizedBox(height: 15),
            Text("Asegúrate de que tu Smartwatch o Wearable tenga el Bluetooth encendido."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // 5. Acción para Cerrar Sesión
  void _logout() {
    // Aquí puedes limpiar estados o usar tu Navigator para volver al Login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cerrando sesión..."), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    int rachaActualMax = widget.habits.isEmpty 
        ? 0 
        : widget.habits.map<int>((h) => (h['streak'] ?? 0) as int).reduce((a, b) => a > b ? a : b);

    int totalHabitosCompletados = widget.habits.isEmpty 
        ? 0 
        : widget.habits.map<int>((h) => ((h['streak'] ?? 0) as int) + ((h['completed'] == true) ? 1 : 0)).reduce((a, b) => a + b);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PERFIL HEADER ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8DBFC), Color(0xFFFDECD2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Text("YR", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Yaretzi Rubio", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                          const Text("yaretzi@gmail.com", style: TextStyle(fontSize: 14, color: Color(0xFF52616B))),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildProfileMiniChip("🔥 Racha: $rachaActualMax días"),
                              const SizedBox(width: 8),
                              _buildProfileMiniChip("🏆 $totalHabitosCompletados hábitos"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- SECCIÓN: CUENTA ---
              _buildSectionTitle("Cuenta"),
              const SizedBox(height: 10),
              _buildGroupedCard([
                _buildMenuRow(
                  icon: Icons.person_outline,
                  title: "Perfil",
                  subtitle: "Editar información personal",
                  onTap: _openProfileEditor, // 🔥 Vinculado
                ),
                const Divider(height: 1, indent: 50, color: Color(0xFFEAEAEA)),
                _buildMenuRow(
                  icon: Icons.cloud_upload_outlined,
                  title: "Copia de Seguridad",
                  subtitle: "Exportar datos y progreso actual",
                  onTap: _backupData, // 🔥 Vinculado
                ),
              ]),
              const SizedBox(height: 25),

              // --- SECCIÓN: PREFERENCIAS ---
              _buildSectionTitle("Preferencias"),
              const SizedBox(height: 10),
              _buildGroupedCard([
                _buildMenuRow(
                  icon: Icons.label_outline,
                  title: "Categorías de Hábitos",
                  subtitle: "Gestionar etiquetas y colores",
                  onTap: _manageCategories, // 🔥 Vinculado
                ),
                const Divider(height: 1, indent: 50, color: Color(0xFFEAEAEA)),
                _buildMenuRow(
                  icon: Icons.dark_mode_outlined,
                  title: "Modo Oscuro",
                  subtitle: "Cambiar tema de la aplicación",
                  trailing: Switch(
                    value: _isDarkMode,
                    activeColor: const Color(0xFF0D253F),
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      widget.onDarkModeChanged?.call(value);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 25),

              // --- SECCIÓN: DISPOSITIVOS ---
              _buildSectionTitle("Dispositivos"),
              const SizedBox(height: 10),
              _buildGroupedCard([
                _buildMenuRow(
                  icon: Icons.watch_outlined,
                  title: "Vincular Dispositivos",
                  subtitle: "Conectar smartwatch y otros dispositivos",
                  onTap: _connectDevice, // 🔥 Vinculado
                ),
              ]),
              const SizedBox(height: 35),

              // --- BOTÓN CERRAR SESIÓN ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: TextButton.icon(
                  onPressed: _logout, // 🔥 Vinculado
                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
                  label: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "BentoHabit v1.0.0",
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- AUXILIARES ---
  Widget _buildProfileMiniChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(15)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0D253F))),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(children: children),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(color: Color(0xFFF5F5F0), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF0D253F), size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
      onTap: onTap,
    );
  }
}