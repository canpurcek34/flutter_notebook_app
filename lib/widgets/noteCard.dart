import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class NoteCard extends StatelessWidget {
  final String id; // Not ID'si
  final String title;
  final String note;
  final String dateTime;
  final Color cardColor;
  final Function(String) onDelete; // Silme işlemi için callback
  final Function(String) onEdit; // Düzenleme işlemi için callback
  final Function(String, Color) onColorChange; // Renk değiştirme callback

  const NoteCard({
    required this.id,
    required this.title,
    required this.note,
    required this.dateTime,
    required this.onDelete, // Silme işlemi için callback'i al
    required this.onEdit, // Düzenleme işlemi için callback'i al
    required this.onColorChange, // Renk değiştirme callback'i al
    this.cardColor = Colors.blueGrey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onEdit(id); // Kart tıklanırsa düzenleme callback'ini çağır
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarih ve Saat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tarih ve Saat
                  Flexible(
                    child: Text(
                      dateTime,
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Uzun metin kısaltılır
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton(
                    onSelected: (value) {
                      if (value == SampleItem.itemOne) {
                        onDelete(id); // Silme işlemi için callback
                      } else if (value == SampleItem.itemTwo) {
                        _showColorPicker(context); // Renk seçimi başlatılıyor
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<SampleItem>>[
                      const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemOne,
                        child: Text('Delete'),
                      ),
                      const PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo,
                        child: Text('Renk Seç'),
                      ),
                    ],
                  ),
                ],
              ),
              // Başlık
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Text(
                      title.isNotEmpty ? title[0].toUpperCase() : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Title için Expanded kullanıyoruz
                  Flexible(
                    child: Container(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Açıklama
              Text(
                note,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color selectedColor = cardColor; // Varsayılan olarak mevcut kart rengi

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bir renk seçin'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                selectedColor = color; // Seçilen renk güncelleniyor
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Diyalog kapatılıyor
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                onColorChange(id, selectedColor); // Renk değiştirme callback'i
                Navigator.of(context).pop(); // Diyalog kapatılıyor
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
