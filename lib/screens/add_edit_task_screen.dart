import 'package:flutter/material.dart';
import '../services/back4app_service.dart';
import '../widgets/custom_textfield.dart';

class AddEditTaskScreen extends StatefulWidget {
  final String sessionToken;
  final String userId;
  final Map<String, dynamic>? task;

  const AddEditTaskScreen({
    super.key,
    required this.sessionToken,
    required this.userId,
    this.task,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen>
    with SingleTickerProviderStateMixin {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final _svc = Back4AppService();
  bool saving = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      titleCtrl.text = widget.task!["title"] ?? "";
      descCtrl.text = widget.task!["description"] ?? "";
    }

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Title cannot be empty")));
      return;
    }

    setState(() => saving = true);

    if (widget.task == null) {
      await _svc.createTask(
        titleCtrl.text.trim(),
        descCtrl.text.trim(),
        widget.sessionToken,
        widget.userId,
      );
    } else {
      await _svc.updateTask(
        widget.task!["objectId"],
        titleCtrl.text.trim(),
        descCtrl.text.trim(),
        widget.sessionToken,
      );
    }

    setState(() => saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8F6AFB), Color(0xFF6E8EF5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        isEditing ? "Edit Task" : "Add New Task",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        isEditing
                            ? "Modify your task details"
                            : "Create a new task",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),

                      const SizedBox(height: 32),

                      // Title input
                      CustomTextField(
                        label: "Task Title",
                        controller: titleCtrl,
                      ),
                      const SizedBox(height: 16),

                      // Description input
                      CustomTextField(
                        label: "Description",
                        controller: descCtrl,
                      ),

                      const SizedBox(height: 28),

                      // Save Button
                      saving
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6E8EF5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  isEditing ? "Save Changes" : "Create Task",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
