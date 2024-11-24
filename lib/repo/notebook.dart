class Notebook {
  final String title;
  final String note;
  final String uuid;

  Notebook({required this.title, required this.note, required this.uuid});

  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
        title: json['title'] as String,
        note: json['note'] as String,
        uuid: json['uuid'] as String);
  }
}
