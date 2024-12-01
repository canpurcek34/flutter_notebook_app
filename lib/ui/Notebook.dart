import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:notebook_app/ui/AddNoteScreen.dart';
import 'package:notebook_app/ui/EditNoteScreen.dart';
import 'package:notebook_app/widgets/NoteCard.dart';

bool isMobile(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth <
      600; // 600 pikselden daha dar ekranlar mobil olarak kabul edilebilir
}

class NotebookScreen extends StatefulWidget {
  @override
  _NotebookScreenState createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<dynamic> _notes = [];
  List<dynamic> _lists = [];
  bool isLoading = true;

  final List<Map<String, dynamic>> _checklists = [];

  final TextEditingController _titleController = TextEditingController();

  void _addChecklist() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        _checklists.add({'title': _titleController.text, 'isChecked': false});
      });
      _titleController.clear();
    }
  }

  @override
  void initState() {
    fetchNotes();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    fetchNotes();
    _tabController?.dispose();
    super.dispose();
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

  Future<void> fetchList() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Kullanıcı oturumu yok");

      final uid = user.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('list') // 'list' koleksiyonuna erişim
          .where('uuid', isEqualTo: uid) // Kullanıcıya özel notlar
          .get();

      setState(() {
        _lists = snapshot.docs
            .map((doc) => {
                  'id': doc.id, // Belge ID'si
                  ...doc.data(), // Diğer alanlar
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      _showError('Firebase listeleri çekerken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notlar ve Listeler"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.note), text: "Notlar"),
            Tab(icon: Icon(Icons.list), text: "Listeler"),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.cyan,
        overlayOpacity: 0.1,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.note_add, color: Colors.white),
            backgroundColor: Colors.cyan,
            label: 'Yeni Not Ekle',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNoteScreen()),
              );
              if (result == true) fetchNotes();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotesTab(),
          _buildListsTab(),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    // Notlar için Staggered GridView

    return MasonryGridView.builder(
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return NoteCard(
          id: note['id'].toString(),
          title: note['title'],
          note: note['note'],
          dateTime: note['date'],
          onDelete: (id) async {
            await deleteNote(id); // Silme işlemi yapılır
            fetchNotes(); // Silmeden sonra notları yenile
          },
          onEdit: (id) async {
            final note = _notes.firstWhere((n) => n['id'].toString() == id);
            if (isMobile(context)) {
              // Mobilde tam ekran navigasyon
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNoteScreen(note: note),
                ),
              );
              if (result == true) fetchNotes();
            } else {
              // Masaüstü için popup
              _openEditNotePopup(context, note);
            }
          },
        );
      },
    );
  }

  Widget _buildListsTab() {
    String formatDate(Timestamp? timestamp) {
      if (timestamp == null) return 'Bilinmiyor';
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}';
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_lists.isEmpty) {
      return const Center(child: Text("Henüz bir liste eklenmemiş."));
    }

    return ListView.builder(
      itemCount: _lists.length,
      itemBuilder: (context, index) {
        final list = _lists[index];
        return ListTile(
          title: Text(list['title'] ?? 'Başlıksız'),
          subtitle: Text(list['note'] ?? ''),
          trailing: Text(
            formatDate(list['date']),
          ), // Tarih gösterimi için
          onTap: () {
            // Düzenleme ekranına yönlendirme
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditNoteScreen(note: list),
              ),
            ).then((value) {
              if (value == true) fetchNotes(); // Düzenlemeden sonra yenile
            });
          },
        );
      },
    );
  }
}
