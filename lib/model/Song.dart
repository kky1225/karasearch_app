class Song {
  final String id;
  final String no;
  final String title;
  final String singer;
  final String music;
  final String lyrics;
  final String media;

  Song({
    required this.id,
    required this.no,
    required this.title,
    required this.singer,
    required this.music,
    required this.lyrics,
    required this.media
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      no: json['no'],
      title: json['title'],
      singer: json['singer'],
      music: json['music'],
      lyrics: json['lyrics'],
      media: json['media']
    );
  }
}