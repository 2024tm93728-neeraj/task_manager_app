import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../services/back4app_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  final _svc = Back4AppService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Login", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            CustomTextField(label: "Email", controller: emailCtrl),
            SizedBox(height: 12),
            CustomTextField(label: "Password", controller: passCtrl, obscureText: true),
            SizedBox(height: 20),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                    onPressed: () async {
                      setState(() => loading = true);
                      final data = await _svc.login(emailCtrl.text.trim(), passCtrl.text.trim());
                      setState(() => loading = false);
                      if (data != null && data["sessionToken"] != null) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
                          HomeScreen(sessionToken: data["sessionToken"], userId: data["objectId"])));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed")));
                      }
                    },
                    child: Text("Login")),
            SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen())),
              child: Text("Don't have an account? Sign up"))
          ]),
        ),
      ),
    );
  }
}
