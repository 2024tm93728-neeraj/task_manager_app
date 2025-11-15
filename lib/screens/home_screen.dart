import 'package:flutter/material.dart';
import '../services/back4app_service.dart';
import 'add_edit_task_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String sessionToken;
  final String userId;
  const HomeScreen({super.key, required this.sessionToken, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _svc = Back4AppService();
  List<dynamic> tasks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Tasks"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          })
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(child: Text("No tasks yet — add one"))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (_, i) {
                      final t = tasks[i] as Map<String, dynamic>;
                      final oid = t["objectId"];
                      return ListTile(
                        title: Text(t["title"] ?? ""),
                        subtitle: Text(t["description"] ?? ""),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: Icon(Icons.edit), onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) =>
                              AddEditTaskScreen(sessionToken: widget.sessionToken, userId: widget.userId, task: t))).then((_) => _load());
                          }),
                          IconButton(icon: Icon(Icons.delete), onPressed: () => _delete(oid)),
                        ]),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) =>
            AddEditTaskScreen(sessionToken: widget.sessionToken, userId: widget.userId))).then((_) => _load());
        }),
    );
  }
}
