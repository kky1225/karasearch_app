import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layout/MediaButton.dart';
import '../model/Song.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({super.key});

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  String media = 'TJ';
  List<Song> bookmarkListAll = [];
  List<Song> bookmarkListFilter = [];

  @override
  void initState() {
    super.initState();
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
                _getBookmarkList();
              });
            }
        ),
        Expanded(
          child: bookmarkListFilter.isEmpty ? Center(child: Text('좋아요 목록이 존재하지 않습니다.')) :
            Scrollbar(
              thumbVisibility: false,
              child: ListView.builder(
                itemCount: bookmarkListFilter.length,
                itemBuilder: (BuildContext context, int index) {
                  final song = bookmarkListFilter[index];
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
                },
              )
          )
        )
      ]
    );
  }
}