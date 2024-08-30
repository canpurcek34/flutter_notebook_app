import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_note_screen.dart';
import 'add_note_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotebookScreen extends StatefulWidget {
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
    print(data); // Verilerin doğru bir şekilde çekilip çekilmediğini kontrol etmek için

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

  Color _getNoteColor(int index) {
    List<Color> colors = [
      Colors.blueGrey.shade900,
      Colors.blue.shade900,
      Colors.green.shade900,
      Colors.orange.shade900,
      Colors.brown.shade900,
      Colors.teal.shade900,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        title: Text("Notebook"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MasonryGridView.builder(
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
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
                color: _getNoteColor(index),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          note['note'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        note['date'],
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
          );
          if (result == true) {
            _fetchNotes(); // Eğer yeni not eklendiyse, notları yeniden çek
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
