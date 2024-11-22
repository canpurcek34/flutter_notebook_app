import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:notebook_app/authpages/loginScreen.dart';
import 'package:notebook_app/ui/add_note_screen.dart';
import 'dart:convert';
import 'package:notebook_app/ui/edit_note_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

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

  bool _isLoading = true;

  Future<void> _fetchNotes() async {
    try {
      final user = FirebaseAuth
          .instance.currentUser; // Firebase'den kullanıcı bilgisi al
      if (user == null) {
        throw Exception("Kullanıcı oturumu yok");
      }
      final uid = user.uid; // UUID'yi al

      // HTTP POST isteği gönder
      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/note/get.php'),
        headers: {
          'Content-Type': 'application/json', // JSON formatı belirtiyoruz
        },
        body: json.encode({'uuid': uid}), // UUID'yi body'de gönderiyoruz
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 1) {
          setState(() {
            _notes = data['data'];
            _isLoading = false; // Veriler başarıyla yüklendi
          });
        } else {
          // Sunucu bir hata mesajı döndürdüyse
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${data['message']}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // HTTP isteği başarısız olduysa
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${response.statusCode}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // İstek sırasında bir hata oluştuysa
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> deleteNote(BuildContext context, String id) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/note/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = json.decode(response.body);

      if (data['success'] == 1) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not başarıyla silindi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchNotes(); // Notları yeniden yükle
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${data['message']}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Oturum durumunu sıfırla

    await FirebaseAuth.instance.signOut(); // Firebase'den çıkış yap

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: RefreshIndicator(
            // Ekranı aşağı çekme ile yenileme
            onRefresh: _fetchNotes, // Yenileme fonksiyonu
            child: Container(
              child: _isLoading
                  ? _buildShimmer()
                  : masonryView(
                      context), // Eğer yükleniyorsa shimmer gösteriyoruz
            ),
          ),
          floatingActionButton: floating(context),
          appBar: AppBar(
            backgroundColor: Colors.cyan,
            title: Text("Notebook"),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _fetchNotes,
              ),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: _logout,
              )
            ],
          )),
    );
  }

  Widget masonryView(BuildContext context) {
    // Ekran genişliğini al
    final screenWidth = MediaQuery.of(context).size.width;

    // Sütun sayısını belirle (mobilde 2, PC'de 4)
    int crossAxisCount = screenWidth < 600 ? 2 : 4;

    return MasonryGridView.builder(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            await deleteNote(
                                context,
                                note['id']
                                    .toString()); // Silme işlemi yapılıyor
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<SampleItem>>[
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
                      maxLines: 10, //maksimum 10 satır halinde görüntüle
                      overflow: TextOverflow
                          .ellipsis, //10.satır sonunda notun devam ettiğini "..." ifadesi ile gösterme
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
          MaterialPageRoute(builder: (context) => AddNoteScreen()),
        );
        if (result == true) {
          _fetchNotes(); // Eğer yeni not eklendiyse, notları yeniden çek
        }
      },
      backgroundColor: Colors.blue,
      child: Icon(Icons.add),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: MasonryGridView.builder(
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: 6, // Yüklenirken kaç tane shimmer gösterileceğini belirleyin
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20.0,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 100.0,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 20.0,
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
