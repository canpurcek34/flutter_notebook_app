import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _note = '';
  

  @override
  void initState() {
    super.initState();
  }

  
  final _date = DateTime.now();

  Future<void> addNote() async {
    

    final response = await http.post(
      Uri.parse('https://emrecanpurcek.com.tr/notebook/insert.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': _title,
        'note': _note,
        'date': _date.toString(),
      }),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (responseData['success'] == 1) {
      Navigator.pop(context, true); // Başarılı olursa geri dön ve listeyi yenile
      print("Yeni veri girişi başarılı.");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseData['message'] ?? 'Bir hata oluştu'),
      ));
      print("Yeni veri girişi başarısız.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Not Ekle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Başlık'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Not'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Not giriniz';
                  }
                  return null;
                },
                onSaved: (value) {
                  _note = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    addNote();
                  }
                },
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
