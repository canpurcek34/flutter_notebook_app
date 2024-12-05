import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AppService {
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
      const type = "note";

      // API çağrısını yap
      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/note/get.php'),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'uuid': uid, 'type': type}), // UUID ve Type gönderiliyor
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
  Future<List<dynamic>> fetchLists() async {
    try {
      final user = _getCurrentUser();
      final uid = user!.uid;
      const type = "list";

      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/list/get.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uuid': uid, 'type': type}),
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

  Future<void> updateCheckbox(int id, bool isChecked) async {
  final response = await http.post(
    Uri.parse("https://yourdomain.com/update.php"),
    body: jsonEncode({
      'id': id,
      'isChecked': isChecked,
    }),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success'] == 1) {
      print("Checkbox durumu güncellendi");
    } else {
      print("Hata: ${data['message']}");
    }
  } else {
    print("Server error: ${response.statusCode}");
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
      final response = await http.post(
        Uri.parse(
            'https://emrecanpurcek.com.tr/projects/methods/list/delete.php'),
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
}
