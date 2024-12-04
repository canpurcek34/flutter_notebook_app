import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:notebook_app/ui/AddListScreen.dart';
import 'package:notebook_app/ui/EditNoteScreen.dart';
import '../widgets/NotesTab.dart';
import '../widgets/ListsTab.dart';
import '../service/AppService.dart';
import 'AddNoteScreen.dart';

class MobileNotebookScreen extends StatefulWidget {
  @override
  _MobileNotebookScreenState createState() => _MobileNotebookScreenState();
}

class _MobileNotebookScreenState extends State<MobileNotebookScreen>
    with SingleTickerProviderStateMixin {
  final AppService _appService = AppService();
  List<dynamic> _notes = [];
  List<dynamic> _lists = [];
  TabController? _tabController;
  bool isLoading = true;

  @override
  void initState() {
    fetchNotes();
    fetchLists();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    fetchNotes();
    fetchLists();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> fetchNotes() async {
    try {
      final notes = await _appService.fetchNotes();
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

  Future<void> fetchLists() async {
    try {
      final lists = await _appService.fetchLists();
      setState(() {
        _lists = lists;
        isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _appService.deleteNote(id);
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

  Future<void> deleteList(String id) async {
    try {
      await _appService.deleteList(id);
      fetchNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Liste başarıyla silindi.'),
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
          SpeedDialChild(
            child: const Icon(Icons.list, color: Colors.white),
            backgroundColor: Colors.cyan,
            label: 'Yeni Liste Ekle',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddListScreen()),
              );
              if (result == true) fetchLists();
            },
          )
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
              lists: _lists,
              onDelete: deleteList,
              onEdit: (id) async {
                final list = _lists.firstWhere((n) => n['id'].toString() == id);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditNoteScreen(note: list), //iyileştirilecek
                  ),
                );
                if (result == true) fetchLists();
              },
              crossCount: 1)
        ],
      ),
    );
  }

  void onChanged(bool bool) {}
}
