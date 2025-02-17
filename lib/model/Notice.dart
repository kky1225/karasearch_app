class Notice {
  final int id;
  final String title;
  final String content;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime regDate;
  final DateTime modDate;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.startDate,
    required this.endDate,
    required this.regDate,
    required this.modDate,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      regDate: DateTime.parse(json['regDate']),
      modDate: DateTime.parse(json['modDate']),
    );
  }
}