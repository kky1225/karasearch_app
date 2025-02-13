import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:karasearch/layout/MediaButton.dart';
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

  @override
  void initState() {
    super.initState();
    _future = Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Row(
          //children: [
            MediaButton(
                media: media,
                onChange: (value) {
                  setState(() {
                    media = value;
                    _future = getSearchSongList(media, category, keyword);
                  });
                }
            ),
          //],
        //),
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
                      border: OutlineInputBorder( // 기본 테두리
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
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
                    focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
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
}