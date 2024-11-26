class ChecklistItem {
  String text;
  bool isChecked;

  ChecklistItem({required this.text, this.isChecked = false});

  ChecklistItem copyWith({String? text, bool? isChecked}) {
    return ChecklistItem(
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
