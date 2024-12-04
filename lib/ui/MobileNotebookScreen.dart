import 'package:flutter/material.dart';
import 'package:notebook_app/ui/EditNoteScreen.dart';
import '../widgets/NotesTab.dart';
import '../widgets/ListsTab.dart';
import '../service/NoteService.dart';
import 'AddNoteScreen.dart';

class MobileNotebookScreen extends StatefulWidget {
  @override
  _MobileNotebookScreenState createState() => _MobileNotebookScreenState();
}

class _MobileNotebookScreenState extends State<MobileNotebookScreen>
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
        title: const Text("Notlar ve Listeler"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.note), text: "Notlar"),
            Tab(icon: Icon(Icons.list), text: "Listeler"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
          );
          if (result == true) fetchNotes();
        },
        child: const Icon(Icons.add),
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
