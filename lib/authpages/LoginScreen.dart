import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notebook_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _keepLoggedIn = false; // Oturumu açık tut seçeneği

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Oturum açık mı kontrol et
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Oturum açık ise direkt NoteScreen'e yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Future<void> login(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;

      if (_keepLoggedIn) {
        // Oturumu açık tut seçeneği aktifse kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }

      // Giriş başarılı, Notebook ekranına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

      if (user != null && !user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('E-posta doğrulanmamış. Lütfen e-postanızı kontrol edin.'),
          ),
        );
        await _auth.signOut(); // Oturumu kapat
      } else {
        // Giriş başarılı, Notebook ekranına yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giriş yap")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                  labelText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                  labelText: "Şifre", border: OutlineInputBorder()),
              obscureText: true,
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                  value: _keepLoggedIn,
                  onChanged: (value) {
                    setState(() {
                      _keepLoggedIn = value ?? false;
                    });
                  },
                ),
                Text("Oturumu açık tut"),
              ],
            ),
            ElevatedButton(
              onPressed: () => login(context),
              child: Text("Giriş Yap"),
            ),
          ],
        ),
      ),
    );
  }
}
