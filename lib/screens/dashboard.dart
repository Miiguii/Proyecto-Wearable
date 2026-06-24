import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'habitos.dart'; 
import 'metas.dart';
import 'stats.dart';
import 'configuracion.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final WatchConnectivity _watch = WatchConnectivity();
  
  late DateTime _today;
  late DateTime _selectedDay;
  late List<DateTime> _weekDays;

  // LISTA
  final List<Map<String, dynamic>> _habits = [
    {'title': 'Leer 30 minutos', 'category': 'Personal', 'type': 'Diario', 'streak': 7, 'completed': true},
    {'title': 'Tomar agua 2L', 'category': 'Personal', 'type': 'Diario', 'streak': 12, 'completed': true},
    {'title': 'Hacer ejercicio', 'category': 'Personal', 'type': '3x semana', 'streak': 5, 'completed': false},
    {'title': 'Estudiar inglés', 'category': 'Trabajo/Escuela', 'type': 'Diario', 'streak': 4, 'completed': false},
    {'title': 'Hacer tarea', 'category': 'Trabajo/Escuela', 'type': 'Diario', 'streak': 15, 'completed': false},
  ];

  // Dentro de class _DashboardScreenState extends State<DashboardScreen>
final List<Map<String, dynamic>> _goals = [
  {
    'title': 'Completar 5 hábitos',
    'desc': 'Marcar como completados todos los hábitos del día',
    'progress': 80,
    'type': 'Diarias',
    'status': 'En progreso',
    'deadline': 'Vence: Hoy',
  },
  {
    'title': 'Estudiar 2 horas',
    'desc': 'Dedicar tiempo a aprender algo nuevo',
    'progress': 50,
    'type': 'Diarias',
    'status': 'En progreso',
    'deadline': 'Vence: Hoy',
  },
];

// Creamos la función para añadir una nueva meta desde el diálogo
void _addNewGoal(Map<String, dynamic> newGoal) {
  setState(() {
    _goals.add(newGoal);
  });
}

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDay = _today;
    _weekDays = _generateCurrentWeek();
  }

  List<DateTime> _generateCurrentWeek() {
    List<DateTime> days = [];
    int daysToSubtract = _today.weekday - DateTime.monday;
    DateTime monday = _today.subtract(Duration(days: daysToSubtract));

    for (int i = 0; i < 6; i++) {
      days.add(monday.add(Duration(days: i)));
    }
    return days;
  }

  // --- FUNCIÓN PARA AGREGAR DESDE OTRAS PANTALLAS ---
  void _addNewHabit(String title, String category, String type) {
    setState(() {
      _habits.add({
        'title': title,
        'category': category,
        'type': type,
        'streak': 0,
        'completed': false,
      });
    });

    // Convertimos la lista a un mapa simple que acepte el canal nativo
    _watch.sendMessage({'habits': _habits});
  }

  // --- FUNCIÓN PARA ELIMINAR UN HÁBITO ---
  void _deleteHabit(int indexInOriginalList) {
    setState(() {
      _habits.removeAt(indexInOriginalList);
    });
  }

  //  PANTALLA DE INICIO
  Widget _buildHomeContent(BuildContext context, int completedCount, double progressPercent, String fechaFormateada, List<String> diasLetra) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ENCABEZADO ---
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFFFB7A2).withOpacity(0.4), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: const [
                      Icon(Icons.local_fire_department, color: Color(0xFFFF6B4A), size: 18),
                      SizedBox(width: 4),
                      Text("15", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                    ],
                  ),
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
                  
                  //Si no hay metas creadas todavía
                  if (_goals.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text("No tienes metas activas para hoy.", style: TextStyle(color: Colors.grey)),
                    )
                  else
                    // Mapeamos dinámicamente tu lista real '_goals'
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _goals.length > 3 ? 3 : _goals.length, // Muestra máximo las primeras 3 en el Inicio
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final goal = _goals[index];
                        double progressDouble = goal['progress'] / 100.0; // Convierte de int (80) a double (0.8)
                        
                        // Alternamos los colores pastel bonitos de tus diseños Bento para cada meta
                        List<Color> pastelColors = [const Color(0xFFD4C7F7), const Color(0xFFFFE382), const Color(0xFFFFB7A2)];
                        Color assignedColor = pastelColors[index % pastelColors.length];

                        return _buildMetaItem(
                          goal['title'], 
                          progressDouble, 
                          "${goal['progress']}%", 
                          assignedColor
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = _habits.where((h) => h['completed'] == true).length;
    double progressPercent = _habits.isEmpty ? 0.0 : completedCount / _habits.length;

    final List<String> meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final List<String> diasLetra = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    String fechaFormateada = "${diasLetra[_today.weekday % 7]}, ${_today.day} de ${meses[_today.month - 1]}";

    // PASAMOS LA LISTA Y LAS FUNCIONES A LAS PANTALLAS CORRESPONDIENTES PARA EL MENUUUUUUUUUUU
    final List<Widget> screens = [
      _buildHomeContent(context, completedCount, progressPercent, fechaFormateada, diasLetra),
      HabitsScreen(
        habits: _habits, 
        onAddHabit: _addNewHabit,
        onDeleteHabit: _deleteHabit,
        onToggleHabit: (index) {
          setState(() {
            _habits[index]['completed'] = !_habits[index]['completed'];
          });

          // ENVIAR ACTUALIZACIÓN AL RELOJ ---------------------------------------------------------------
          _watch.sendMessage({'habits': _habits});
        },
      ),
      GoalsScreen( // Actualizado con la función requerida
        goals: _goals,
        onAddGoal: _addNewGoal,
        onUpdateGoalProgress: (index, newProgress) {
          setState(() {
            _goals[index]['progress'] = newProgress;
            if (newProgress == 100) {
              _goals[index]['status'] = 'Completado';
            } else {
              _goals[index]['status'] = 'En progreso';
            }
          });
        },
      ),

      StatsScreen(
        habits: _habits,
        goals: _goals,
      ),
      
      ConfigScreen(
        habits: _habits,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: screens[_selectedIndex],
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
            items: List.generate(5, (index) {
              final labels = ['Inicio', 'Hábitos', 'Metas', 'Stats', 'Config'];
              final icons = [Icons.home_filled, Icons.check_box_outlined, Icons.track_changes, Icons.trending_up, Icons.settings_outlined];
              return BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == index ? const Color(0xFFFFE382) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icons[index]),
                ),
                label: labels[index],
              );
            }),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE INICIO ---
  Widget _buildCalendarDay(DateTime day, String label, String number, {bool isCompleted = false}) {
    bool isSelected = _selectedDay.year == day.year && _selectedDay.month == day.month && _selectedDay.day == day.day;
    Color bgColor = isSelected ? const Color(0xFFFFE382) : (isCompleted ? const Color(0xFFC1EAD1) : const Color(0xFFF8F9FA));

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
            if (isCompleted) const Icon(Icons.check_circle, size: 14, color: Color(0xFF2B7A4B))
            else Icon(Icons.circle_outlined, size: 14, color: isSelected ? Colors.transparent : Colors.black12),
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
            Icon(completed ? Icons.check_circle : Icons.circle_outlined, color: completed ? const Color(0xFF2B7A4B) : Colors.grey),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0D253F), decoration: completed ? TextDecoration.lineThrough : null)),
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
          child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: const Color(0xFFF0F2F5), color: barColor),
        ),
      ],
    );
  }
}