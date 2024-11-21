import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
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
  String? formattedDate; // Formatlanmış tarih

  @override
  void initState() {
    super
        .initState(); //initialize edip ilgili note cardına tıkladığımızda verilerin o ekrana geçmesini sağlıyor
    _titleController.text = widget.note['title'] ?? '';
    _noteController.text = widget.note['note'] ?? '';
    _date = widget.note['date'] ??
        DateFormat.yMMMMd('tr_TR')
            .add_jm()
            .toString(); //tarih formatı düzenlenecek
  }

  Future<void> updateNote() async {
    // Tarih formatını başlatıyoruz ve ardından formatlı tarihi alıyoruz
    await initializeDateFormatting('tr_TR', null); // Yerel ayarları başlat
    final now = DateTime.now();
    formattedDate = DateFormat('d MMMM y HH:mm', 'tr_TR')
        .format(now); // Tarihi formatlıyoruz

    // HTTP POST isteği gönderiliyor
    final response = await http.post(
      Uri.parse('https://emrecanpurcek.com.tr/projects/methods/update.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': widget.note['id'], // Notun ID'si
        'title': _titleController.text, // Güncellenmiş başlık
        'note': _noteController.text, // Güncellenmiş not
        'date':
            formattedDate ?? now.toString(), // Formatlanmış tarihi gönderiyoruz
      }),
    );

    // Gelen cevabı işliyoruz
    final data = json.decode(response.body);

    if (data['success'] == 1) {
      Navigator.pop(context, true); // Başarılı ise geri dön
      print("Veri güncellenmesi başarılı");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${data['message']}'),
          behavior: SnackBarBehavior.floating,
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
        title: Text('Düzenle'),
        actions: [
          /*IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              setState(() {
                updateNote();
              });
            },
          ),*/
        ],
      ),
      // SingleChildScrollView for scrollable content
      body: SingleChildScrollView(
        child: Padding(
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
                      //labelText: 'Title',
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
                      //labelText: 'Note',
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Text(
                          'Düzenlenme Zamanı: $_date',
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  updateNote();

                  print(_titleController.text);
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
