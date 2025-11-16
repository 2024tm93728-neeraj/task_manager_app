import 'package:flutter/material.dart';
import '../services/back4app_service.dart';
import 'add_edit_task_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String sessionToken;
  final String userId;

  const HomeScreen({
    super.key,
    required this.sessionToken,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _svc = Back4AppService();
  List<dynamic> tasks = [];
  bool loading = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _load();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    tasks = await _svc.getTasks(widget.sessionToken, widget.userId);
    setState(() => loading = false);
  }

  Future<void> _delete(String id) async {
    final ok = await _svc.deleteTask(id, widget.sessionToken);
    if (ok) _load();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inbox_rounded,
          size: 100,
          color: Colors.white.withOpacity(.8),
        ),
        const SizedBox(height: 12),
        Text(
          "No tasks yet",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white.withOpacity(.9),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Add your first task using + button",
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(.8)),
        ),
      ],
    );
  }

  Widget _taskCard(Map<String, dynamic> task) {
    return Dismissible(
      key: Key(task["objectId"]),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (_) => _delete(task["objectId"]),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task["title"] ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF444444),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task["description"] ?? "",
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditTaskScreen(
                      sessionToken: widget.sessionToken,
                      userId: widget.userId,
                      task: task,
                    ),
                  ),
                ).then((_) => _load());
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8F6AFB), Color(0xFF6E8EF5), Color(0xFF5ABDF1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Your Tasks",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : tasks.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            itemCount: tasks.length,
                            itemBuilder: (_, i) => _taskCard(tasks[i]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Floating button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTaskScreen(
                sessionToken: widget.sessionToken,
                userId: widget.userId,
              ),
            ),
          ).then((_) => _load());
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.blueAccent, size: 30),
      ),
    );
  }
}
