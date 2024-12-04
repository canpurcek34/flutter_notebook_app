import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotebookService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Hata mesajı döndüren yardımcı bir metod
  String _handleError(dynamic error) {
    return error.toString();
  }

  /// Kullanıcı doğrulamasını kontrol eden yardımcı bir metod
  User? _getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu yok");
    return user;
  }

  /// Notları çekmek için kullanılan metod (Sunucudan HTTP ile)
  Future<List<dynamic>> fetchNotes() async {
    try {
      final user = _getCurrentUser();
      final uid = user!.uid;

      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/note/get.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uuid': uid}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 1) {
          return data['data'];
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('HTTP Hata Kodu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Notları çekmek için kullanılan metod (Firebase Firestore ile)
  Future<List<Map<String, dynamic>>> fetchLists() async {
    try {
      final user = _getCurrentUser();
      final uid = user!.uid;

      final snapshot = await _firestore
          .collection('list')
          .where('uuid', isEqualTo: uid)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id, // Belge ID'si
                ...doc.data(), // Diğer alanlar
              })
          .toList();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Sunucudan not silme işlemi
  Future<void> deleteNote(String id) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/note/delete.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      final data = json.decode(response.body);
      if (data['success'] != 1) {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Firebase Firestore'dan bir not silme işlemi
  Future<void> deleteList(String id) async {
    try {
      await _firestore.collection('list').doc(id).delete();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
