import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:notebook_app/add_note_screen.dart';
import 'dart:convert';

import 'package:notebook_app/edit_note_screen.dart';


enum SampleItem { itemOne, itemTwo, itemThree }

class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key});

  @override
  _NotebookScreenState createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  List<dynamic> _notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final response = await http.get(
      Uri.parse('https://emrecanpurcek.com.tr/notebook/get.php'),
    );

    final data = json.decode(response.body);
    print(
        data); // Verilerin doğru bir şekilde çekilip çekilmediğini kontrol etmek için

    if (data['success'] == 1) {
      setState(() {
        _notes = data['data'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${data['message']}')),
      );
    }
  }

  Future<void> deleteNote(BuildContext context, String id) async {
  final response = await http.post(
    Uri.parse('https://emrecanpurcek.com.tr/notebook/delete.php'),
    body: {'id': id},
  );

  final data = json.decode(response.body);

  if (data['success'] == 1) {
    // Başarılı silme işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Note deleted successfully')),
    );
  } else {
    // Hata mesajı
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${data['message']}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          child: masonryView(context),
        ),
        floatingActionButton: floating(context),
        appBar: AppBar(
          title: Text("Flutter Note App"),
          backgroundColor: Colors.cyan,
        ),
      ),
    );
  }

  Widget masonryView(BuildContext context) {
  return MasonryGridView.builder(
    gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    itemCount: _notes.length,
    itemBuilder: (context, index) {
      final note = _notes[index];
      return GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditNoteScreen(note: note),
            ),
          );
          if (result == true) {
            _fetchNotes(); // Eğer not başarıyla güncellendiyse, notları yeniden çek
          }
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Bu satırı ekleyin
                  children: [
                    Text(
                      note['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    PopupMenuButton(
                      onSelected: (value) async {
                        if (value == SampleItem.itemOne) {
                          // Silme işlemi
                          await deleteNote(context, note['id']);

                          // Ekranı güncellemek için setState ile _fetchNotes çağrısı
                          setState(() {
                            _fetchNotes();
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
                        const PopupMenuItem<SampleItem>(
                          value: SampleItem.itemOne,
                          child: Text('Delete'),
                        ),
                      ],
                    ),

                  ],
                ),
                SizedBox(height: 8.0),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    note['note'],
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  note['date'],
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  Widget floating(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNoteScreen()
              ),
            );
            if (result == true) {
              _fetchNotes(); // Eğer yeni not eklendiyse, notları yeniden çek
            }
          },
      child: Icon(Icons.add),
      backgroundColor: Colors.blue,
    );
  }
}
