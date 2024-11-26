import 'package:flutter/material.dart';
import 'package:notebook_app/widgets/ChecklistItem.dart';

class EditChecklistScreen extends StatefulWidget {
  final Function(String, String, List<ChecklistItem>) onSave;

  const EditChecklistScreen({required this.onSave, super.key});

  @override
  _EditChecklistScreenState createState() => _EditChecklistScreenState();
}

class _EditChecklistScreenState extends State<EditChecklistScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<ChecklistItem> _items = [];

  void _addItem() {
    setState(() {
      _items.add(ChecklistItem(text: "Yeni Öğe"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Liste Oluştur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(
                DateTime.now().toString(),
                _titleController.text,
                _items,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Liste Başlığı',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Row(
                    children: [
                      Checkbox(
                        value: item.isChecked,
                        onChanged: (value) {
                          setState(() {
                            item.isChecked = value!;
                          });
                        },
                      ),
                      Flexible(
                        child: TextField(
                          onChanged: (value) {
                            item.text = value;
                          },
                          decoration: InputDecoration(
                            hintText: 'Öğe ${index + 1}',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Yeni Öğe Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
