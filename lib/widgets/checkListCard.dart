import 'package:flutter/material.dart';
import 'package:notebook_app/widgets/ChecklistItem.dart';

class ChecklistCard extends StatelessWidget {
  final String id;
  final String title;
  final List<ChecklistItem> items;
  final Function(String) onDelete;
  final Function(String) onEdit;
  final Function(String, ChecklistItem) onToggle;

  const ChecklistCard({
    required this.id,
    required this.title,
    required this.items,
    required this.onDelete,
    required this.onEdit,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onEdit(id); // Düzenleme işlevi
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () => onDelete(id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Checklist Öğeleri
            Column(
              children: items.map((item) {
                return Row(
                  children: [
                    Checkbox(
                      value: item.isChecked,
                      onChanged: (value) {
                        onToggle(id, item.copyWith(isChecked: value!));
                      },
                    ),
                    Flexible(
                      child: Text(
                        item.text,
                        style: TextStyle(
                          decoration: item.isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
