class PopularSong {
  final String id;
  final int ranking;
  final String no;
  final String title;
  final String singer;
  final String media;
  final String year;
  final String month;

  PopularSong({
    required this.id,
    required this.ranking,
    required this.no,
    required this.title,
    required this.singer,
    required this.media,
    required this.year,
    required this.month
  });

  factory PopularSong.fromJson(Map<String, dynamic> json) {
    return PopularSong(
      id: json['id'],
      ranking: json['ranking'],
      no: json['no'],
      title: json['title'],
      singer: json['singer'],
      media: json['media'],
      year: json['year'],
      month: json['month']
    );
  }
}