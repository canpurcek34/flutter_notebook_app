

class Notebook {
  final String title;
  final String note;

  Notebook({required this.title, required this.note});

  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
      title: json['title'] as String,
      note: json['note'] as String,
    );
  }
}
