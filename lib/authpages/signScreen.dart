import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kaydol'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email TextField
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-posta Adresi',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                // Username TextField
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // Full Name TextField
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Ad Soyad',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // Password TextField
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true, // Şifreyi gizlemek için
                ),
                SizedBox(height: 24),
                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    String email = _emailController.text;
                    String username = _usernameController.text;
                    String fullName = _fullNameController.text;
                    String password = _passwordController.text;

                    // Kayıt işlemini burada gerçekleştirin
                    if (email.isNotEmpty &&
                        username.isNotEmpty &&
                        fullName.isNotEmpty &&
                        password.isNotEmpty) {
                      print(
                          'E-posta: $email, Kullanıcı Adı: $username, Ad Soyad: $fullName, Şifre: $password');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kayıt Başarılı!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tüm alanlar doldurulmalıdır!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Kayıt Ol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
