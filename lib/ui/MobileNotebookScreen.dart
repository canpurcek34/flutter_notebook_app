import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:notebook_app/ui/AddListScreen.dart';
import 'package:notebook_app/ui/EditListScreen.dart';
import 'package:notebook_app/widgets/ListsTab.dart';
import 'package:notebook_app/widgets/NotesTab.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../service/AppService.dart';
import 'AddNoteScreen.dart';
import 'EditNoteScreen.dart';

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
  bool isChecked = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
    //_refreshController.dispose();
    super.dispose();
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
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const ClassicHeader(), // Doğru header tipi
          footer:
              const ClassicFooter(), // Yükleme için bir footer eklenmesi önerilir
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: TabBarView(
            controller: _tabController,
            children: [
              NotesTab(
                crossCount: cross,
                notes: _notes,
                onDelete: deleteNote,
                onEdit: (id) async {
                  final note =
                      _notes.firstWhere((n) => n['id'].toString() == id);
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
                isChecked: isChecked,
                onEdit: (id) async {
                  final list =
                      _lists.firstWhere((n) => n['id'].toString() == id);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditListScreen(list: list),
                    ),
                  );
                  if (result == true) fetchLists();
                },
                crossCount: cross,
                onChanged: (String id, bool value) {
                  setState(() {
                    updateCheckbox(id, value);
                  });
                },
              ),
            ],
          ),
        ));
  }

  Future<void> fetchNotes() async {
    try {
      final notes = await _appService.fetchNotes();
      setState(() {
        // Son güncelleme tarihine göre sıralama
        _notes = notes..sort((a, b) => b['date'].compareTo(a['date']));
        isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> fetchLists() async {
    try {
      final lists = await _appService.fetchLists();
      setState(() {
        // Son güncelleme tarihine göre sıralama
        _lists = lists..sort((a, b) => b['date'].compareTo(a['date']));
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

  Future<void> updateCheckbox(String id, bool value) async {
    try {
      await _appService.updateCheckbox(id, value);
      setState(() {
        fetchLists();
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
      fetchLists();
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

  void _onRefresh() async {
    try {
      await fetchNotes();
      await fetchLists();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  void _onLoading() async {
    try {
      await fetchNotes();
      await fetchLists();
      _refreshController.loadComplete();
    } catch (e) {
      _refreshController.loadFailed();
    }
  }
}
