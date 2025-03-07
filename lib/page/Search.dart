import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:karasearch/layout/MediaButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/Notice.dart';
import '../model/Song.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String media = 'TJ';
  String category = 'title';
  String keyword = '';
  late Future<List<Song>> _future;
  List<Notice> noticeList = [];

  List<Song> bookmarkListAll = [];
  List<Song> bookmarkListFilter = [];

  @override
  void initState() {
    super.initState();
    _future = Future.value([]);
    getNoticeList();
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
                _future = getSearchSongList(media, category, keyword);
                _getBookmarkList();
              });
            }
        ),
        Row(
            children: [
              SizedBox(
                  width: 80,
                  child:
                  DropdownButtonFormField<String>(
                    value: category,
                    items: [{'label': '제목', 'value': 'title'}, {'label': '가수', 'value': 'singer'}].map((value) {
                      return DropdownMenuItem<String>(
                        value: value['value'],
                        child: Text(value['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                        _future = getSearchSongList(media, category, keyword);
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                    ),

                  )
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blueAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          keyword = value;
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          _future = getSearchSongList(media, category, keyword);
                        });
                      },
                    ),
                  )
              )
            ]
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

  Future<void> noticePopup(int index) async {
    if(index >= noticeList.length) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final key = 'never_show_notice_${noticeList[index].id}';

    bool isNeverShow = prefs.getBool(key) ?? false;

    if(isNeverShow) {
      noticePopup(index + 1);
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(noticeList[index].title),
                  content: Text(noticeList[index].content),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: CheckboxListTile(
                              title: Text(
                                "다시는 보지 않기",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              value: isNeverShow,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  setState(() {
                                    isNeverShow = value;
                                  });
                                }
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            )
                        ),
                        TextButton(
                          onPressed: () async {
                            if(isNeverShow) {
                              await prefs.setBool(key, isNeverShow);
                            }
                            Navigator.of(context).pop();
                            noticePopup(index + 1);
                          },
                          child: Text("닫기"),
                        )
                      ],
                    )
                  ],
                );
              }
          );
        }
    );
  }

  Future<List<Song>> getSearchSongList(String media, String category, String keyword) async {
    try {
      final url = Uri.parse('http://13.124.181.85:8080/v1/api/song/search').replace(
          queryParameters: {
            "category": category,
            "keyword": keyword,
            "media": media
          }
      );

      final res = await http.get(url);

      if(res.statusCode != 200 ) {
        throw Exception('노래 검색 실패');
      }

      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(res.bodyBytes));
      final List<dynamic> jsonList = jsonResponse['list'];

      return jsonList.map((json) => Song.fromJson(json)).toList();
    }catch(e) {
      throw Exception('노래 검색 실패');
    }
  }

  Future<void> getNoticeList() async {
    try {
      final url = Uri.parse('http://13.124.181.85:8080/v1/api/notice/popupList');

      final res = await http.get(url);

      if(res.statusCode != 200 ) {
        throw Exception('공지사항 조회 실패');
      }

      final data = json.decode(utf8.decode(res.bodyBytes));

      setState(() {
        noticeList = List<Notice>.from(data.map((value) => Notice.fromJson(value)).toList());
      });

      if(noticeList.isNotEmpty) {
        noticePopup(0);
      }
    }catch (e) {
      throw Exception('공지사항 조회 실패');
    }
  }
}