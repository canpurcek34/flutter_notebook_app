import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    _date = widget.note['date'] ?? DateTime.now().toString();
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
        SnackBar(content: Text('Hata: ${data['message']}')),
      );
      print("Veri güncellenmesi başarısız");
      print("----------------------------");
      print(widget.note['id']);
      print(_titleController.text);
      print(_noteController.text);
      print(_date);
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
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Note'),
                maxLines: 6,
              ),
              SizedBox(height: 16),
              Text(
                'Düzenlenme zamanı: $_date', // Salt okunur tarih
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'id: $id ', // Salt okunur id
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
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
