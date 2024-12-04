import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notebook_app/ui/EditNoteScreen.dart';

class ListsTab extends StatelessWidget {
  final List<dynamic> lists;
  final bool isLoading;
  final Function() fetchNotes;
  final int crossCount;

  const ListsTab({
    super.key,
    required this.lists,
    required this.isLoading,
    required this.fetchNotes,
    required this.crossCount,
  });

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Bilinmiyor';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lists.isEmpty) {
      return const Center(child: Text("Henüz bir liste eklenmemiş."));
    }

    return ListView.builder(
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        return ListTile(
          title: Text(list['title'] ?? 'Başlıksız'),
          subtitle: Text(list['note'] ?? ''),
          trailing: Text(formatDate(list['date'])),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditNoteScreen(note: list),
              ),
            ).then((value) {
              if (value == true) fetchNotes();
            });
          },
        );
      },
    );
  }
}
