import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  // LAS VARIABLES DEFECHAS SE DECLARAN AQUÍ
  late DateTime _today;
  late DateTime _selectedDay;
  late List<DateTime> _weekDays;

  // Estado de los hábitos
  final List<Map<String, dynamic>> _habits = [
    {'title': 'Leer 30 minutos', 'category': 'Personal', 'completed': true},
    {'title': 'Tomar agua 2L', 'category': 'Personal', 'completed': true},
    {'title': 'Hacer ejercicio', 'category': 'Personal', 'completed': false},
    {'title': 'Estudiar inglés', 'category': 'Trabajo/Escuela', 'completed': false},
  ];

  // SE INICIALIZAN AQUÍ AL CARGAR EL COMPONENTE
  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDay = _today;
    _weekDays = _generateCurrentWeek();
  }

  // Genera los días de la semana actual (de Lunes a Sábado)
  List<DateTime> _generateCurrentWeek() {
    List<DateTime> days = [];
    int daysToSubtract = _today.weekday - DateTime.monday;
    DateTime monday = _today.subtract(Duration(days: daysToSubtract));

    for (int i = 0; i < 6; i++) {
      days.add(monday.add(Duration(days: i)));
    }
    return days;
  }

  // EL MÉTODO BUILD COMIENZA AQUÍ SIN INTERRUPCIONES
  @override
  Widget build(BuildContext context) {
    // Cálculo dinámico del progreso
    int completedCount = _habits.where((h) => h['completed'] == true).length;
    double progressPercent = _habits.isEmpty ? 0.0 : completedCount / _habits.length;

    // Formateadores de fecha en español
    final List<String> meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final List<String> diasLetra = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    
    String fechaFormateada = "${diasLetra[_today.weekday % 7]}, ${_today.day} de ${meses[_today.month - 1]}";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ENCABEZADO  (falta arreglar algunos detalles como la rachaaaaa y el icono)---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFFFE382),
                        child: Text("YR", style: TextStyle(color: Color(0xFF0D253F), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("¡Hola, Yaretzi\nRubio!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2, color: Color(0xFF0D253F))),
                          const SizedBox(height: 2),
                          Text(fechaFormateada, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFFFB7A2).withOpacity(0.4), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: const [
                            Icon(Icons.local_fire_department, color: Color(0xFFFF6B4A), size: 18),
                            SizedBox(width: 4),
                            Text("7", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- CALENDARIO SEMANAL ---
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_weekDays.length, (index) {
                    DateTime day = _weekDays[index];
                    String label = diasLetra[day.weekday % 7];
                    String number = day.day.toString();
                    bool isCompleted = day.isBefore(_today) && day.day != _today.day;

                    return _buildCalendarDay(day, label, number, isCompleted: isCompleted);
                  }),
                ),
              ),
              const SizedBox(height: 15),

              // --- CARD PROGRESO GENERAL ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE3DCF7), Color(0xFFFFF3D1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Progreso General", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text("${(progressPercent * 100).toInt()}%", style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
                            const SizedBox(width: 8),
                            const Text("completado\nhoy", style: TextStyle(fontSize: 13, color: Colors.blueGrey, height: 1.1)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("$completedCount de ${_habits.length} hábitos", style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            value: progressPercent,
                            backgroundColor: Colors.white.withOpacity(0.5),
                            color: Colors.white,
                            strokeWidth: 10,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text("$completedCount/${_habits.length}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // --- SECCIÓN: HÁBITOS DE HOY ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Hábitos de hoy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                    const SizedBox(height: 15),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _habits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final habit = _habits[index];
                        return _buildHabitItem(index, habit['title'], habit['category'], habit['completed']);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // --- SECCIÓN: METAS ACTIVAS ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Metas activas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                    const SizedBox(height: 20),
                    _buildMetaItem("Completar curso de React", 0.65, "65%", const Color(0xFFD4C7F7)),
                    const SizedBox(height: 20),
                    _buildMetaItem("Leer 3 libros este mes", 0.33, "33%", const Color(0xFFFFE382)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF0D253F),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0 ? const Color(0xFFFFE382) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.home_filled),
                ),
                label: 'Inicio',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: 'Hábitos'),
              const BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Metas'),
              const BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Stats'),
              const BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Config'),
            ],
          ),
        ),
      ),
    );
  }

  // widgets auxiliares

  Widget _buildCalendarDay(DateTime day, String label, String number, {bool isCompleted = false}) {
    bool isSelected = _selectedDay.year == day.year && 
                      _selectedDay.month == day.month && 
                      _selectedDay.day == day.day;
                      
    Color bgColor = isSelected 
        ? const Color(0xFFFFE382) 
        : (isCompleted ? const Color(0xFFC1EAD1) : const Color(0xFFF8F9FA));

    return GestureDetector(
      onTap: () => setState(() => _selectedDay = day),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(number, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
            const SizedBox(height: 5),
            if (isCompleted)
              const Icon(Icons.check_circle, size: 14, color: Color(0xFF2B7A4B))
            else
              Icon(Icons.circle_outlined, size: 14, color: isSelected ? Colors.transparent : Colors.black12),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitItem(int index, String title, String category, bool completed) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _habits[index]['completed'] = !_habits[index]['completed'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: completed ? const Color(0xFFC1EAD1) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              completed ? Icons.check_circle : Icons.circle_outlined,
              color: completed ? const Color(0xFF2B7A4B) : Colors.grey,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D253F),
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(category, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(String title, double progress, String percentText, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0D253F))),
            Text(percentText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFF0F2F5),
            color: barColor,
          ),
        ),
      ],
    );
  }
}