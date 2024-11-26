import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:notebook_app/ui/edit_note_screen.dart';
import 'package:notebook_app/widgets/noteCard.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'add_note_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

bool isMobile() {
  if (kIsWeb) return false; // Web için masaüstü davranışı
  return Platform.isAndroid || Platform.isIOS; // Mobil platformlar
}

class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key});

  @override
  NotebookScreenState createState() => NotebookScreenState();
}

class NotebookScreenState extends State<NotebookScreen> {
  List<dynamic> _notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  void _openEditNotePopup(BuildContext context, Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 500, // Popup genişliği (masaüstü için uygun)
          child: EditNoteScreen(
              note: note), // Düzenleme ekranını burada çağırıyoruz
        ),
      ),
    );
  }

  Future<void> fetchNotes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Kullanıcı oturumu yok");
      final uid = user.uid;

      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/note/get.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uuid': uid}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 1) {
          setState(() {
            _notes = data['data'];
            isLoading = false;
          });
        } else {
          _showError(data['message']);
        }
      } else {
        _showError('Hata: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Bir hata oluştu: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> deleteNote(String id) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/note/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      final data = json.decode(response.body);
      if (data['success'] == 1) {
        fetchNotes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not başarıyla silindi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showError(data['message']);
      }
    } catch (e) {
      _showError('Bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Notebook"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchNotes),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.note_add),
                    title: const Text('Yeni Not Ekle'),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddNoteScreen()),
                      );
                      if (result == true) fetchNotes();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_box),
                    title: const Text('Yeni Liste Ekle'),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddNoteScreen()),
                      );
                      if (result == true) fetchNotes();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: fetchNotes,
        child: isLoading ? buildShimmer() : masonryView(context),
      ),
    );
  }

  Widget masonryView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth < 600 ? 2 : 4;

    return MasonryGridView.builder(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return NoteCard(
          id: note['id'].toString(), // Not ID'sini aktar
          title: note['title'],
          note: note['note'],
          dateTime: note['date'],
          onColorChange: (id, color) {
            print('Not rengi değiştirildi: $id, Yeni Renk: $color');
          },
          onDelete: (id) async {
            await deleteNote(id); // Silme işlemi yapılır
            fetchNotes(); // Silmeden sonra notları yenile
          },
          onEdit: (id) async {
            final note = _notes.firstWhere((n) => n['id'].toString() == id);
            if (isMobile()) {
              // Mobilde tam ekran navigasyon
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNoteScreen(note: note),
                ),
              );
              if (result == true)
                fetchNotes(); // Geri döndüğünde notları yenile
            } else {
              // Masaüstü için popup
              _openEditNotePopup(context, note);
            }
          },
        );
      },
    );
  }

  Widget buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: MasonryGridView.builder(
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 20.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 100.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
