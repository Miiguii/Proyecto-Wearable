import 'package:flutter/material.dart';

class GoalsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> goals;
  final Function(Map<String, dynamic>) onAddGoal;
  final Function(int, int) onUpdateGoalProgress; // Para actualizar el progreso desde aquí

  const GoalsScreen({
    super.key,
    required this.goals,
    required this.onAddGoal,
    required this.onUpdateGoalProgress,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String _selectedTab = 'Diarias'; // Controla la pestaña activa

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, StateSetter setModalState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD4C7F7),
              onPrimary: Color(0xFF0D253F),
              onSurface: Color(0xFF0D253F),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDeadline) {
      setModalState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _showAddGoalDialog() {
    _titleController.clear();
    _descController.clear();
    _selectedDeadline = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            String fechaTexto = _selectedDeadline == null
                ? "Seleccionar fecha de término"
                : "Termina el: ${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}";

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              padding: EdgeInsets.only(
                top: 25,
                left: 25,
                right: 25,
                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nueva Meta (${_selectedTab})", // Te avisa en qué pestaña se va a guardar
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Título de la meta",
                        filled: true,
                        fillColor: const Color(0xFFF0F2F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                        hintText: "Descripción o detalle",
                        filled: true,
                        fillColor: const Color(0xFFF0F2F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () => _selectDate(context, setModalState),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
                        decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF5A67D8), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              fechaTexto,
                              style: TextStyle(
                                color: _selectedDeadline == null ? Colors.grey[600] : const Color(0xFF0D253F),
                                fontWeight: _selectedDeadline == null ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_titleController.text.trim().isNotEmpty) {
                            widget.onAddGoal({
                              'title': _titleController.text.trim(),
                              'desc': _descController.text.trim().isEmpty ? 'Sin descripción' : _descController.text.trim(),
                              'progress': 0, // Empieza en 0% para ir completándola diariamente
                              'type': _selectedTab, // 🌟 SE ASIGNA AUTOMÁTICAMENTE A LA PESTAÑA SELECCIONADA
                              'status': 'En progreso',
                              'deadline': _selectedDeadline == null 
                                  ? 'Vence: Fin de ciclo' 
                                  : 'Vence: ${_selectedDeadline!.day}/${_selectedDeadline!.month}',
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFE382),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text("Añadir Meta", style: TextStyle(color: Color(0xFF0D253F), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar las metas usando la lista del widget padre
    List<Map<String, dynamic>> filteredGoals = widget.goals.where((g) => g['type'] == _selectedTab).toList();

    int completadas = filteredGoals.where((g) => g['progress'] == 100).length;
    int enProgreso = filteredGoals.where((g) => g['progress'] > 0 && g['progress'] < 100).length;
    int pendientes = filteredGoals.where((g) => g['progress'] == 0).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mis Metas", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                      Text("${filteredGoals.length} metas ${_selectedTab.toLowerCase()}", style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddGoalDialog,
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFF0D253F)),
                    label: const Text("Nueva", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4C7F7),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),

            // --- FILTROS PESTAÑAS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Diarias', 'Semanales', 'Mensuales'].map((tabName) {
                  bool isSelected = _selectedTab == tabName;
                  return InkWell(
                    onTap: () => setState(() => _selectedTab = tabName),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(color: isSelected ? const Color(0xFFD4C7F7) : Colors.white, borderRadius: BorderRadius.circular(25)),
                      child: Text(tabName, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF0D253F) : Colors.black87)),
                    ),
                  );
                }).toList(),
              ),
            ),

            // --- CONTENIDO SCROLLABLE ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // RESUMEN BENTO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Resumen", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSummaryMiniBox("$completadas", "Completadas", const Color(0xFFC1EAD1)),
                              _buildSummaryMiniBox("$enProgreso", "En progreso", const Color(0xFFFFF3D1)),
                              _buildSummaryMiniBox("$pendientes", "Pendientes", const Color(0xFFFFB7A2)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // LISTADO DE TARJETAS
                    if (filteredGoals.isEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 40),
                        child: const Text("No hay metas registradas.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.goals.length, // Iteramos sobre la lista global
                        separatorBuilder: (_, __) => const SizedBox(height: 0), // Manejado por el filtro interno
                        itemBuilder: (context, index) {
                          final goal = widget.goals[index];
                          // Validamos que solo pinte las tarjetas correspondientes a la pestaña activa
                          if (goal['type'] != _selectedTab) return const SizedBox.shrink();

                          int progress = goal['progress'];
                          bool isDone = progress == 100;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: Text(goal['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: isDone ? const Color(0xFFC1EAD1) : const Color(0xFFFFF3D1), borderRadius: BorderRadius.circular(15)),
                                      child: Text(goal['status'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDone ? const Color(0xFF2B7A4B) : const Color(0xFFB7791F))),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(goal['desc'], style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                const SizedBox(height: 15),
                                
                                // 🌟 SECCIÓN INTERACTIVA: SUBIR PROGRESO DIARIAMENTE (+25% por toque)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Text("Progreso: ", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                                        Text("$progress%", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                                      ],
                                    ),
                                    if (!isDone)
                                      IconButton(
                                        icon: const Icon(Icons.add_circle, color: Color(0xFFD4C7F7), size: 28),
                                        onPressed: () {
                                          int nextProgress = progress + 25; // Sube de 25 en 25 por ejemplo
                                          if (nextProgress > 100) nextProgress = 100;
                                          widget.onUpdateGoalProgress(index, nextProgress);
                                        },
                                      )
                                    else
                                      const Icon(Icons.check_circle, color: Color(0xFF2B7A4B), size: 28),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress / 100,
                                    minHeight: 12,
                                    backgroundColor: const Color(0xFFF0F2F5),
                                    valueColor: AlwaysStoppedAnimation<Color>(isDone ? const Color(0xFFC1EAD1) : const Color(0xFFFFE382)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF5A67D8)),
                                    const SizedBox(width: 6),
                                    Text(goal['deadline'], style: const TextStyle(color: Color(0xFF5A67D8), fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMiniBox(String value, String label, Color bgColor) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(color: bgColor.withOpacity(0.7), borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
        ],
      ),
    );
  }
}