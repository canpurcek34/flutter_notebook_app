import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:notebook_app/widgets/ListsTab.dart';
import 'package:notebook_app/widgets/NotesTab.dart';
import '../service/NoteService.dart';
import 'AddNoteScreen.dart';
import 'EditNoteScreen.dart';

bool isMobile(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth <
      600; // 600 pikselden daha dar ekranlar mobil olarak kabul edilebilir
}

class DesktopNotebookScreen extends StatefulWidget {
  @override
  _DesktopNotebookScreenState createState() => _DesktopNotebookScreenState();
}

class _DesktopNotebookScreenState extends State<DesktopNotebookScreen>
    with SingleTickerProviderStateMixin {
  final NotebookService _notebookService = NotebookService();
  List<dynamic> _notes = [];
  List<dynamic> _lists = [];
  TabController? _tabController;
  bool isLoading = true;

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

  Future<void> fetchNotes() async {
    try {
      final notes = await _notebookService.fetchNotes();
      setState(() {
        _notes = notes;
        isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> deleteNote(String id) async {
    try {
      await _notebookService.deleteNote(id);
      fetchNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not başarıyla silindi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var cross = 1;

    if (screenWidth < 600) {
      // Mobil ekran
      cross = 1;
    } else {
      // Masaüstü ekran
      cross = 4;
    }
    return Scaffold(
      appBar: AppBar(
        title: null,
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
          NotesTab(
            crossCount: cross,
            notes: _notes,
            onDelete: deleteNote,
            onEdit: (id) async {
              final note = _notes.firstWhere((n) => n['id'].toString() == id);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNoteScreen(note: note),
                ),
              );
              if (result == true) fetchNotes();
            },
          ),
          ListsTab(
            crossCount: cross,
            lists: _lists,
            isLoading: isLoading,
            fetchNotes: fetchNotes,
          ),
        ],
      ),
    );
  }
}
