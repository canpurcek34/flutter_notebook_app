import 'dart:convert';
import 'package:http/http.dart' as http;

class NoteService {
  // Notları alacak olan method
  Future<void> fetchNotes(String uid) async {
    try {
      final response = await http.post(
        Uri.parse('https://emrecanpurcek.com.tr/projects/methods/note/get.php'),
        headers: {
          'Authorization': 'Bearer $uid', // Kullanıcı token'ı
        },
        body: jsonEncode(<String, String>{
          'uuid': uid, // Kullanıcı ID'si
        }),
      );

      if (response.statusCode == 200) {
        print('Notlar başarıyla alındı: ${response.body}');
      } else {
        print('Veri çekme hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('HTTP isteği sırasında hata: $e');
    }
  }
}
