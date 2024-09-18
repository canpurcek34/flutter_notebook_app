import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  EditNoteScreen({required this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late String _date;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note['title'] ?? '';
    _noteController.text = widget.note['note'] ?? '';
    _date = widget.note['date'] ?? DateFormat.yMMMMd('en_US').add_jm(); //tarih formatı düzenlenecek
  }

  Future<void> _updateNote() async {
    final response = await http.post(
      Uri.parse('https://emrecanpurcek.com.tr/notebook/update.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': widget.note['id'],
        'title': _titleController.text,
        'note': _noteController.text,
        'date': _date,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final data = json.decode(response.body);

    if (data['success'] == 1) {
      Navigator.pop(context, true);
      print("Veri güncellenmesi başarılı");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${data['message']}'),
          behavior: SnackBarBehavior.floating
          ),
      );
      print("Veri güncellenmesi başarısız");
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.note['id'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              setState(() {
                _updateNote();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title TextField
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Gölgenin konumu
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Note TextField
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note',
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  minLines: 1, // Minimum satır sayısı
                  maxLines: null, // Metin büyüdükçe yüksekliği artırır
                  expands: false, // Dinamik genişlemeyi sağlar
                ),
              ),
            ),
            SizedBox(height: 16),
            // Date and ID in a Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date Container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        'Düzenlenme zamanı: $_date',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // ID Container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        'id: $id',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Save Button
            ElevatedButton(
              onPressed: () {
                _updateNote();
              },
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}