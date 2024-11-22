import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // İçeriği dikey ortalar
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Elemanları genişletir
            children: [
              // Username TextField
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
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
              // Login Button
              ElevatedButton(
                onPressed: () {
                  String username = _usernameController.text;
                  String password = _passwordController.text;

                  // Giriş işlemini burada gerçekleştirin
                  if (username.isNotEmpty && password.isNotEmpty) {
                    print('Kullanıcı Adı: $username, Şifre: $password');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Giriş Başarılı!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kullanıcı adı ve şifre gerekli!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Giriş Yap'),
              ),
              SizedBox(height: 16),
              // Forgot Password
              TextButton(
                onPressed: () {
                  // Şifre sıfırlama işlemleri için buraya yönlendirme yapılabilir
                  print('Şifremi unuttum tıklandı');
                },
                child: Text('Şifremi Unuttum'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
