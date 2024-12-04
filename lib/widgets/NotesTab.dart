import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/NoteCard.dart';

class NotesTab extends StatelessWidget {
  final List<dynamic> notes;
  final Function(String id) onDelete;
  final Function(String id) onEdit;
  final int crossCount;

  const NotesTab(
      {super.key,
      required this.notes,
      required this.onDelete,
      required this.onEdit,
      required this.crossCount});

  @override
  Widget build(BuildContext context) {
    int cross = crossCount;

    return MasonryGridView.builder(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          id: note['id'].toString(),
          title: note['title'],
          note: note['note'],
          dateTime: note['date'],
          onDelete: onDelete,
          onEdit: onEdit,
        );
      },
    );
  }
}
