import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

class HabitsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> habits;
  final Function(String, String, String) onAddHabit;
  final Function(int) onDeleteHabit;
  final Function(int) onToggleHabit;

  const HabitsScreen({
    super.key,
    required this.habits,
    required this.onAddHabit,
    required this.onDeleteHabit,
    required this.onToggleHabit,
  });

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  String _selectedCategory = 'Todos';

  void _showAddHabitModal(BuildContext context) {
    final TextEditingController habitController = TextEditingController();
    String selectedModalCategory = 'Personal';
    String selectedFrecuency = 'Diario';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F5F0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 25,
                left: 25,
                right: 25,
                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 30),
                      const Text(
                        "Añadir Nuevo Hábito",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D253F),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Nombre del hábito",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D253F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: habitController,
                    decoration: InputDecoration(
                      hintText: "Ej: Leer 30 minutos",
                      hintStyle: const TextStyle(color: Colors.grey),
                      fillColor: const Color(0xFFF0F2F5),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Categoría",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D253F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedModalCategory,
                        isExpanded: true,
                        items:
                            ['Personal', 'Trabajo/Escuela']
                                .map(
                                  (val) => DropdownMenuItem(
                                    value: val,
                                    child: Text(
                                      val,
                                      style: const TextStyle(
                                        color: Color(0xFF0D253F),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (newValue) => setModalState(
                              () => selectedModalCategory = newValue!,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Frecuencia",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D253F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFrecuency,
                        isExpanded: true,
                        items:
                            ['Diario', '3x semana', 'Fin de semana']
                                .map(
                                  (val) => DropdownMenuItem(
                                    value: val,
                                    child: Text(
                                      val,
                                      style: const TextStyle(
                                        color: Color(0xFF0D253F),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (newValue) => setModalState(
                              () => selectedFrecuency = newValue!,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (habitController.text.isNotEmpty) {
                          // LLAMAMOS A LA FUNCIÓN DEL DASHBOARD PADRE
                          widget.onAddHabit(
                            habitController.text,
                            selectedModalCategory,
                            selectedFrecuency,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC1EAD1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Crear Hábito",
                        style: TextStyle(
                          color: Color(0xFF0D253F),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ss = ScreenSize.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ss.maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ss.gap(20),
                vertical: ss.gap(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mis Hábitos",
                              style: TextStyle(
                                fontSize: ss.font(26),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0D253F),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: ss.gap(2)),
                            Text(
                              "${widget.habits.length} hábitos",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: ss.font(15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: ss.gap(8)),
                      ElevatedButton.icon(
                        onPressed: () => _showAddHabitModal(context),
                        icon: Icon(
                          Icons.add,
                          color: const Color(0xFF0D253F),
                          size: ss.icon(18),
                        ),
                        label: Text(
                          "Añadir",
                          style: TextStyle(
                            color: const Color(0xFF0D253F),
                            fontWeight: FontWeight.bold,
                            fontSize: ss.font(14),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFE382),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ss.gap(20)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildCategoryFilter('Todos', Icons.book_outlined, ss),
                        SizedBox(width: ss.gap(10)),
                        _buildCategoryFilter(
                          'Trabajo/Escuela',
                          Icons.business_center_outlined,
                          ss,
                        ),
                        SizedBox(width: ss.gap(10)),
                        _buildCategoryFilter(
                          'Personal',
                          Icons.person_outline,
                          ss,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ss.gap(20)),
                  Expanded(
                    child: ListView.separated(
                      itemCount: widget.habits.length,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (_, __) => SizedBox(height: ss.gap(12)),
                      itemBuilder: (context, index) {
                        final habit = widget.habits[index];

                        // Filtrado visual
                        if (_selectedCategory != 'Todos' &&
                            habit['category'] != _selectedCategory) {
                          return const SizedBox.shrink();
                        }

                        return _buildHabitCard(
                          ss: ss,
                          originalIndex: index,
                          title: habit['title'],
                          category: habit['category'],
                          type: habit['type'] ?? 'Diario',
                          streak: habit['streak'] ?? 0,
                          completed: habit['completed'] ?? false,
                        );
                      },
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

  Widget _buildCategoryFilter(String title, IconData icon, ScreenSize ss) {
    bool isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = title),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ss.gap(20),
          vertical: ss.gap(12),
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE382) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF0D253F), size: ss.icon(18)),
            SizedBox(width: ss.gap(8)),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D253F),
                fontSize: ss.font(15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard({
    required ScreenSize ss,
    required int originalIndex,
    required String title,
    required String category,
    required String type,
    required int streak,
    required bool completed,
  }) {
    Color catColor =
        category == 'Personal'
            ? const Color(0xFFC1EAD1)
            : const Color(0xFFD4C7F7);

    return Container(
      padding: ss.paddingAll(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: ss.font(17),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D253F),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: ss.gap(8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ss.gap(10),
                        vertical: ss.gap(4),
                      ),
                      decoration: BoxDecoration(
                        color: catColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: ss.font(11),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0D253F),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ss.gap(12)),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: ss.icon(14),
                      color: Colors.blue,
                    ),
                    SizedBox(width: ss.gap(4)),
                    Flexible(
                      child: Text(
                        type,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: ss.font(13),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: ss.gap(15)),
                    Icon(
                      Icons.local_fire_department,
                      size: ss.icon(16),
                      color: Colors.orange,
                    ),
                    SizedBox(width: ss.gap(2)),
                    Text(
                      "$streak días",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: ss.font(13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => widget.onToggleHabit(originalIndex),
                icon: Icon(
                  completed ? Icons.check_circle : Icons.circle_outlined,
                  size: ss.icon(22),
                  color: completed ? const Color(0xFF2B7A4B) : Colors.grey,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      completed
                          ? const Color(0xFFC1EAD1)
                          : const Color(0xFFF0F2F5),
                  padding: ss.paddingAll(8),
                ),
              ),
              SizedBox(width: ss.gap(8)),
              IconButton(
                onPressed: () => widget.onDeleteHabit(originalIndex),
                icon: Icon(
                  Icons.delete_outline,
                  size: ss.icon(20),
                  color: Colors.redAccent,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEBEA),
                  padding: ss.paddingAll(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
