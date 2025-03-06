import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../layout/MediaButton.dart';
import '../model/PopularSong.dart';

class Popular extends StatefulWidget {
  const Popular({super.key});
  
  @override
  State<Popular> createState() => _PopularSongState();
}

class _PopularSongState extends State<Popular> {
  String media = 'TJ';
  String year = DateTime.now().month - 1 == 0 ? (DateTime.now().year - 1).toString() : DateTime.now().year.toString();
  String month = DateTime.now().month - 1 == 0 ? "12" : (DateTime.now().month - 1).toString().padLeft(2, '0');
  late Future<List<PopularSong>> _future;

  @override
  void initState() {
    super.initState();
    _future = getPopularSongList(media, year, month);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MediaButton(
                  media: media,
                  onChange: (value) {
                    setState(() {
                      media = value;
                      _future = getPopularSongList(media, year, month);
                    });
                  }
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: SizedBox(
                        height: 60,
                        width: 90,
                        child:
                        DropdownButtonFormField<String>(
                            value: year,
                            items: ['2023', '2024', '2025'].map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                year = value!;
                                _future = getPopularSongList(media, year, month);
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
                          )
                        ),

                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: SizedBox(
                        height: 60,
                        width: 70,
                        child:
                        DropdownButtonFormField<String>(
                            value: month,
                            items: ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'].map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                month = value!;
                                _future = getPopularSongList(media, year, month);
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
                            )
                        )
                    ),
                  )
                ],
              )
            ],
          ),
          Expanded(
              child: FutureBuilder<List<PopularSong>>(
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
                                leading: CircleAvatar(
                                  backgroundColor:
                                    index == 0 ? Colors.amber[300] : index == 1 ? Colors.grey[400] : index == 2 ? Colors.brown[200] : Colors.grey[200] ,
                                  child: Text(
                                    '${song.ranking}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MediaButton(
                media: media,
                onChange: (value) {
                  setState(() {
                    media = value;
                    _future = getPopularSongList(media, year, month);
                  });
                }
            ),
            //Expanded(
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width:70,
                  child:
                  DropdownButtonFormField<String>(
                    value: year,
                    items: ['2023', '2024', '2025'].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        year = value!;
                        _future = getPopularSongList(media, year, month);
                      });
                    }
                  )
                )
              ],
            )//)
          ],
        ),
        Expanded(
            child: FutureBuilder<List<PopularSong>>(
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
                              leading: CircleAvatar(
                                backgroundColor:
                                  index == 0 ? Colors.amber[300] : index == 1 ? Colors.grey[400] : index == 2 ? Colors.brown[200] : Colors.grey[200] ,
                                child: Text(
                                  '${song.ranking}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: index == 0 ? Colors.black : Colors.black54,
                                  ),
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

  Future<List<PopularSong>> getPopularSongList(String media, String year, String month) async {
    try {
      final url = Uri.parse('http://13.124.181.85:8080/v1/api/song/popularSong').replace(
          queryParameters: {
            "media": media,
            "year": year,
            "month": month,
          }
      );

      final res = await http.get(url);

      if(res.statusCode != 200 ) {
        throw Exception('노래 검색 실패');
      }

      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(res.bodyBytes));
      final List<dynamic> jsonList = jsonResponse['list'];

      return jsonList.map((json) => PopularSong.fromJson(json)).toList();
    }catch(e) {
      throw Exception('노래 검색 실패');
    }
  }
}