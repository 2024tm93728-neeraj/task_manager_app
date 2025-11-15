import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../services/back4app_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool loading = false;
  final _svc = Back4AppService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: Text("Sign Up")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(children: [
            CustomTextField(label: "Email", controller: emailCtrl),
            SizedBox(height: 12),
            CustomTextField(label: "Password", controller: passCtrl, obscureText: true),
            SizedBox(height: 12),
            CustomTextField(label: "Confirm Password", controller: confirmCtrl, obscureText: true),
            SizedBox(height: 18),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                  onPressed: () async {
                    if (passCtrl.text != confirmCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match")));
                      return;
                    }
                    setState(() => loading = true);
                    final res = await _svc.signUp(emailCtrl.text.trim(), passCtrl.text.trim());
                    setState(() => loading = false);
                    if (res != null && (res["objectId"] != null)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup successful — please login")));
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup failed")));
                    }
                  },
                  child: Text("Create Account")),
          ]),
        ),
      ),
    );
  }
}
