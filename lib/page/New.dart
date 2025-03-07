import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../layout/MediaButton.dart';
import '../model/Song.dart';
import 'package:http/http.dart' as http;

class New extends StatefulWidget {
  const New({super.key});

  @override
  State<New> createState() => _NewState();
}

class _NewState extends State<New> {
  String media = 'TJ';
  late Future<List<Song>> _future;

  List<Song> bookmarkListAll = [];
  List<Song> bookmarkListFilter = [];

  @override
  void initState() {
    super.initState();
    _future = getNewSongList(media);
    _getBookmarkList();
  }

  Future<void> _getBookmarkList() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkListString = prefs.getString('bookmarkList');

    if (bookmarkListString != null) {
      final List<dynamic> bookmarkListJson = jsonDecode(bookmarkListString);
      setState(() {
        bookmarkListAll = bookmarkListJson.map((json) => Song.fromJson(json)).toList();
        bookmarkListFilter = bookmarkListAll.where((song) => song.media == media).toList();
      });
    }
  }

  Future<void> _updateBookmarkList() async {
    bookmarkListAll = bookmarkListFilter + bookmarkListAll.where((bookmark) => bookmark.media != media).toList();

    final prefs = await SharedPreferences.getInstance();
    final bookmarkListJson = bookmarkListAll.map((song) => song.toJson()).toList();
    prefs.setString('bookmarkList', jsonEncode(bookmarkListJson));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          MediaButton(
              media: media,
              onChange: (value) {
                setState(() {
                  media = value;
                  _future = getNewSongList(media);
                  _getBookmarkList();
                });
              }
          ),
          SizedBox(height: 5),
          Expanded(
              child: FutureBuilder<List<Song>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류가 발생했습니다.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('검색 결과가 없습니다.'));
                  } else {
                    final songs = snapshot.data!;

                    return Scrollbar(
                        thumbVisibility: false,
                        child: ListView.builder(
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              final isFavorite = bookmarkListFilter.any((bookmark) => bookmark.id == song.id);

                              return ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    song.no,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),

                                title: Text(song.title),
                                subtitle: Text(song.singer),
                                trailing: IconButton(
                                  icon: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border
                                  ),
                                  color: Colors.red,
                                  onPressed: () {
                                    setState(() {
                                      if(isFavorite) {
                                        bookmarkListFilter.removeWhere((bookmark) => bookmark.id == song.id);
                                      }else {
                                        bookmarkListFilter.add(
                                            Song(
                                                id: song.id,
                                                no: song.no,
                                                title: song.title,
                                                singer: song.singer,
                                                music: song.music,
                                                lyrics: song.lyrics,
                                                media: song.media
                                            )
                                        );
                                      }
                                    });
                                    _updateBookmarkList();
                                  },
                                ),
                              );
                            }
                        )
                    );
                  }
                },
              )
          )
        ],
      );
  }

  Future<List<Song>> getNewSongList(String media) async {
    try {
      final url = Uri.parse('http://13.124.181.85:8080/v1/api/song/newSong').replace(
          queryParameters: {
            "media": media
          }
      );

      final res = await http.get(url);

      if(res.statusCode != 200 ) {
        throw Exception('노래 검색 실패');
      }

      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(res.bodyBytes));
      final List<dynamic> jsonList = jsonResponse['list'];

      print(jsonList);

      return jsonList.map((json) => Song.fromJson(json)).toList();
    }catch(e) {
      throw Exception('노래 검색 실패');
    }
  }
}