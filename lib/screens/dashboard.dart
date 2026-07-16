import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/ble_server_service.dart';
import '../utils/screen_size.dart';
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

  // El teléfono es el SERVIDOR GATT; el reloj (goalify_watch) es el cliente.
  final BleServerService _bleServer = BleServerService();
  StreamSubscription<Map<String, dynamic>>? _commandSub;
  bool _isDarkMode = false;
  int _nextHabitId = 0;
  int _nextGoalId = 0;

  late DateTime _today;
  late DateTime _selectedDay;
  late List<DateTime> _weekDays;

  // LISTA. Cada item lleva un 'id' estable: el reloj lo usa para referenciar
  // el hábito/meta exacto en sus comandos (toggle_habit, update_goal).
  final List<Map<String, dynamic>> _habits = [
    {
      'id': 'h0',
      'title': 'Leer 30 minutos',
      'category': 'Personal',
      'type': 'Diario',
      'streak': 7,
      'completed': true,
    },
    {
      'id': 'h1',
      'title': 'Tomar agua 2L',
      'category': 'Personal',
      'type': 'Diario',
      'streak': 12,
      'completed': true,
    },
    {
      'id': 'h2',
      'title': 'Hacer ejercicio',
      'category': 'Personal',
      'type': '3x semana',
      'streak': 5,
      'completed': false,
    },
    {
      'id': 'h3',
      'title': 'Estudiar inglés',
      'category': 'Trabajo/Escuela',
      'type': 'Diario',
      'streak': 4,
      'completed': false,
    },
    {
      'id': 'h4',
      'title': 'Hacer tarea',
      'category': 'Trabajo/Escuela',
      'type': 'Diario',
      'streak': 15,
      'completed': false,
    },
  ];

  // Dentro de class _DashboardScreenState extends State<DashboardScreen>
  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'g0',
      'title': 'Completar 5 hábitos',
      'desc': 'Marcar como completados todos los hábitos del día',
      'progress': 80,
      'type': 'Diarias',
      'status': 'En progreso',
      'deadline': 'Vence: Hoy',
    },
    {
      'id': 'g1',
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
      _goals.add({'id': 'g${_nextGoalId++ + 100}', ...newGoal});
    });
    _pushStateToWatch();
  }

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDay = _today;
    _weekDays = _generateCurrentWeek();
    _nextHabitId = _habits.length;
    _nextGoalId = _goals.length;
    _initBleServer();
  }

  Future<void> _initBleServer() async {
    final granted = await _bleServer.requestPermissions();
    if (!granted) {
      // Sin estos permisos el reloj nunca va a poder encontrar/conectarse
      // al teléfono. Podrías mostrar un diálogo explicando por qué se necesitan.
      return;
    }
    await _bleServer.start();
    _pushStateToWatch(); // Sincroniza el estado inicial en cuanto arranca.
    _commandSub = _bleServer.commands.listen(_handleWatchCommand);
  }

  /// Empuja habits + goals + config al reloj. Se llama después de CADA
  /// mutación de estado (agregar/tocar hábito, agregar/avanzar meta, tema).
  void _pushStateToWatch() {
    _bleServer.pushState(
      habits: _habits,
      goals: _goals,
      isDarkMode: _isDarkMode,
    );
  }

  /// Procesa comandos que llegan del reloj (toggle_habit, update_goal).
  void _handleWatchCommand(Map<String, dynamic> command) {
    final action = command['action'];
    if (action == 'toggle_habit') {
      final id = command['id'];
      final idx = _habits.indexWhere((h) => h['id'] == id);
      if (idx != -1) {
        setState(() {
          _habits[idx]['completed'] = !_habits[idx]['completed'];
        });
        _pushStateToWatch();
      }
    } else if (action == 'update_goal') {
      final id = command['id'];
      final progress = command['progress'];
      final idx = _goals.indexWhere((g) => g['id'] == id);
      if (idx != -1 && progress is int) {
        setState(() {
          _goals[idx]['progress'] = progress;
          _goals[idx]['status'] =
              progress >= 100 ? 'Completado' : 'En progreso';
        });
        _pushStateToWatch();
      }
    }
  }

  @override
  void dispose() {
    _commandSub?.cancel();
    _bleServer.stop();
    _bleServer.dispose();
    super.dispose();
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
        'id': 'h${_nextHabitId++}',
        'title': title,
        'category': category,
        'type': type,
        'streak': 0,
        'completed': false,
      });
    });

    _pushStateToWatch();
  }

  // --- FUNCIÓN PARA ELIMINAR UN HÁBITO ---
  void _deleteHabit(int indexInOriginalList) {
    setState(() {
      _habits.removeAt(indexInOriginalList);
    });
  }

  //  PANTALLA DE INICIO
  Widget _buildHomeContent(
    BuildContext context,
    int completedCount,
    double progressPercent,
    String fechaFormateada,
    List<String> diasLetra,
  ) {
    final ss = ScreenSize.of(context);
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ss.maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ss.gap(20),
              vertical: ss.gap(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ENCABEZADO ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: ss.gap(24),
                            backgroundColor: const Color(0xFFFFE382),
                            child: Text(
                              "YR",
                              style: TextStyle(
                                fontSize: ss.font(14),
                                color: const Color(0xFF0D253F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: ss.gap(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "¡Hola, Yaretzi\nRubio!",
                                  style: TextStyle(
                                    fontSize: ss.font(20),
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                    color: const Color(0xFF0D253F),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: ss.gap(2)),
                                Text(
                                  fechaFormateada,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: ss.font(13),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: ss.gap(8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ss.gap(10),
                        vertical: ss.gap(6),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB7A2).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: const Color(0xFFFF6B4A),
                            size: ss.icon(18),
                          ),
                          SizedBox(width: ss.gap(4)),
                          Text(
                            "15",
                            style: TextStyle(
                              fontSize: ss.font(14),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D253F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ss.gap(20)),

                // --- CALENDARIO SEMANAL ---
                Container(
                  padding: ss.paddingAll(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: List.generate(_weekDays.length, (index) {
                      DateTime day = _weekDays[index];
                      String label = diasLetra[day.weekday % 7];
                      String number = day.day.toString();
                      bool isCompleted =
                          day.isBefore(_today) && day.day != _today.day;

                      // Expanded en vez de tamaño fijo: los 6 días se
                      // reparten el ancho disponible y nunca se salen
                      // de pantalla, sin importar el tamaño del teléfono.
                      return Expanded(
                        child: _buildCalendarDay(
                          day,
                          label,
                          number,
                          isCompleted: isCompleted,
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: ss.gap(15)),

                // --- CARD PROGRESO GENERAL ---
                Container(
                  width: double.infinity,
                  padding: ss.paddingAll(25),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Progreso General",
                              style: TextStyle(
                                fontSize: ss.font(17),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0D253F),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: ss.gap(15)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "${(progressPercent * 100).toInt()}%",
                                  style: TextStyle(
                                    fontSize: ss.font(38),
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0D253F),
                                  ),
                                ),
                                SizedBox(width: ss.gap(8)),
                                Flexible(
                                  child: Text(
                                    "completado\nhoy",
                                    style: TextStyle(
                                      fontSize: ss.font(13),
                                      color: Colors.blueGrey,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: ss.gap(8)),
                            Text(
                              "$completedCount de ${_habits.length} hábitos",
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: ss.font(14),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: ss.gap(10)),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: ss.gap(80),
                            height: ss.gap(80),
                            child: CircularProgressIndicator(
                              value: progressPercent,
                              backgroundColor: Colors.white.withOpacity(0.5),
                              color: Colors.white,
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Text(
                            "$completedCount/${_habits.length}",
                            style: TextStyle(
                              fontSize: ss.font(20),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D253F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ss.gap(15)),

                // --- SECCIÓN: HÁBITOS DE HOY ---
                Container(
                  width: double.infinity,
                  padding: ss.paddingAll(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hábitos de hoy",
                        style: TextStyle(
                          fontSize: ss.font(18),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D253F),
                        ),
                      ),
                      SizedBox(height: ss.gap(15)),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _habits.length,
                        separatorBuilder:
                            (_, __) => SizedBox(height: ss.gap(12)),
                        itemBuilder: (context, index) {
                          final habit = _habits[index];
                          return _buildHabitItem(
                            index,
                            habit['title'],
                            habit['category'],
                            habit['completed'],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ss.gap(15)),

                // --- SECCIÓN: METAS ACTIVAS ---
                Container(
                  width: double.infinity,
                  padding: ss.paddingAll(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Metas activas",
                        style: TextStyle(
                          fontSize: ss.font(18),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D253F),
                        ),
                      ),
                      SizedBox(height: ss.gap(20)),

                      //Si no hay metas creadas todavía
                      if (_goals.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: ss.gap(10)),
                          child: const Text(
                            "No tienes metas activas para hoy.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        // Mapeamos dinámicamente tu lista real '_goals'
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              _goals.length > 3
                                  ? 3
                                  : _goals
                                      .length, // Muestra máximo las primeras 3 en el Inicio
                          separatorBuilder:
                              (_, __) => SizedBox(height: ss.gap(20)),
                          itemBuilder: (context, index) {
                            final goal = _goals[index];
                            double progressDouble =
                                goal['progress'] /
                                100.0; // Convierte de int (80) a double (0.8)

                            // Alternamos los colores pastel bonitos de tus diseños Bento para cada meta
                            List<Color> pastelColors = [
                              const Color(0xFFD4C7F7),
                              const Color(0xFFFFE382),
                              const Color(0xFFFFB7A2),
                            ];
                            Color assignedColor =
                                pastelColors[index % pastelColors.length];

                            return _buildMetaItem(
                              goal['title'],
                              progressDouble,
                              "${goal['progress']}%",
                              assignedColor,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ss = ScreenSize.of(context);
    int completedCount = _habits.where((h) => h['completed'] == true).length;
    double progressPercent =
        _habits.isEmpty ? 0.0 : completedCount / _habits.length;

    final List<String> meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final List<String> diasLetra = [
      'Dom',
      'Lun',
      'Mar',
      'Mié',
      'Jue',
      'Vie',
      'Sáb',
    ];
    String fechaFormateada =
        "${diasLetra[_today.weekday % 7]}, ${_today.day} de ${meses[_today.month - 1]}";

    // PASAMOS LA LISTA Y LAS FUNCIONES A LAS PANTALLAS CORRESPONDIENTES PARA EL MENUUUUUUUUUUU
    final List<Widget> screens = [
      _buildHomeContent(
        context,
        completedCount,
        progressPercent,
        fechaFormateada,
        diasLetra,
      ),
      HabitsScreen(
        habits: _habits,
        onAddHabit: _addNewHabit,
        onDeleteHabit: _deleteHabit,
        onToggleHabit: (index) {
          setState(() {
            _habits[index]['completed'] = !_habits[index]['completed'];
          });

          // ENVIAR ACTUALIZACIÓN AL RELOJ (servidor GATT vía BLE) --------------
          _pushStateToWatch();
        },
      ),
      GoalsScreen(
        // Actualizado con la función requerida
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
          _pushStateToWatch();
        },
      ),

      StatsScreen(habits: _habits, goals: _goals),

      ConfigScreen(
        habits: _habits,
        onDarkModeChanged: (value) {
          setState(() => _isDarkMode = value);
          _pushStateToWatch();
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF0D253F),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ss.font(12),
            ),
            unselectedLabelStyle: TextStyle(fontSize: ss.font(12)),
            items: List.generate(5, (index) {
              final labels = ['Inicio', 'Hábitos', 'Metas', 'Stats', 'Config'];
              final icons = [
                Icons.home_filled,
                Icons.check_box_outlined,
                Icons.track_changes,
                Icons.trending_up,
                Icons.settings_outlined,
              ];
              return BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ss.gap(16),
                    vertical: ss.gap(8),
                  ),
                  decoration: BoxDecoration(
                    color:
                        _selectedIndex == index
                            ? const Color(0xFFFFE382)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icons[index], size: ss.icon(24)),
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
  Widget _buildCalendarDay(
    DateTime day,
    String label,
    String number, {
    bool isCompleted = false,
  }) {
    final ss = ScreenSize.of(context);
    bool isSelected =
        _selectedDay.year == day.year &&
        _selectedDay.month == day.month &&
        _selectedDay.day == day.day;
    Color bgColor =
        isSelected
            ? const Color(0xFFFFE382)
            : (isCompleted ? const Color(0xFFC1EAD1) : const Color(0xFFF8F9FA));

    return GestureDetector(
      onTap: () => setState(() => _selectedDay = day),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ss.gap(10),
          vertical: ss.gap(12),
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: ss.font(12),
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ss.gap(5)),
            Text(
              number,
              style: TextStyle(
                fontSize: ss.font(16),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D253F),
              ),
            ),
            SizedBox(height: ss.gap(5)),
            if (isCompleted)
              Icon(
                Icons.check_circle,
                size: ss.icon(14),
                color: const Color(0xFF2B7A4B),
              )
            else
              Icon(
                Icons.circle_outlined,
                size: ss.icon(14),
                color: isSelected ? Colors.transparent : Colors.black12,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitItem(
    int index,
    String title,
    String category,
    bool completed,
  ) {
    final ss = ScreenSize.of(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          _habits[index]['completed'] = !_habits[index]['completed'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: ss.paddingAll(15),
        decoration: BoxDecoration(
          color: completed ? const Color(0xFFC1EAD1) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              completed ? Icons.check_circle : Icons.circle_outlined,
              size: ss.icon(24),
              color: completed ? const Color(0xFF2B7A4B) : Colors.grey,
            ),
            SizedBox(width: ss.gap(15)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ss.font(16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D253F),
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: ss.font(12),
                      color: Colors.blueGrey,
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

  Widget _buildMetaItem(
    String title,
    double progress,
    String percentText,
    Color barColor,
  ) {
    final ss = ScreenSize.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ss.font(15),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0D253F),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              percentText,
              style: TextStyle(
                fontSize: ss.font(14),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D253F),
              ),
            ),
          ],
        ),
        SizedBox(height: ss.gap(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: ss.gap(10),
            backgroundColor: const Color(0xFFF0F2F5),
            color: barColor,
          ),
        ),
      ],
    );
  }
}
