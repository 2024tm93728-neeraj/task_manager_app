import 'package:flutter/material.dart';
import '../services/back4app_service.dart';
import '../widgets/custom_textfield.dart';

class AddEditTaskScreen extends StatefulWidget {
  final String sessionToken;
  final String userId;
  final Map<String, dynamic>? task;

  const AddEditTaskScreen({super.key, required this.sessionToken, required this.userId, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final _svc = Back4AppService();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleCtrl.text = widget.task!["title"] ?? "";
      descCtrl.text = widget.task!["description"] ?? "";
    }
  }

  Future<void> _save() async {
    setState(() => saving = true);
    if (widget.task == null) {
      await _svc.createTask(titleCtrl.text.trim(), descCtrl.text.trim(), widget.sessionToken, widget.userId);
    } else {
      await _svc.updateTask(widget.task!["objectId"], titleCtrl.text.trim(), descCtrl.text.trim(), widget.sessionToken);
    }
    setState(() => saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? "Add Task" : "Edit Task")),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(children: [
          CustomTextField(label: "Title", controller: titleCtrl),
          SizedBox(height: 12),
          CustomTextField(label: "Description", controller: descCtrl),
          SizedBox(height: 20),
          saving ? CircularProgressIndicator() : ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
            child: Text("Save"),
          )
        ]),
      ),
    );
  }
}
