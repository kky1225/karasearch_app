import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../layout/Header.dart';
import '../model/Notice.dart';

class NoticeList extends StatefulWidget {
  const NoticeList({super.key});

  @override
  State<NoticeList> createState() => _NoticeState();
}

class _NoticeState extends State<NoticeList> {
  late Future<List<Notice>> _future;

  @override
  void initState() {
    super.initState();
    _future = getNoticeList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Header(title: '공지사항'),
        body: Row(
            children: [
              Expanded(
                  child: FutureBuilder<List<Notice>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('오류가 발생했습니다.'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('검색 결과가 없습니다.'));
                      } else {
                        final noticeList = snapshot.data!;

                        return Scrollbar(
                            thumbVisibility: false,
                            child: ListView.builder(
                                itemCount: noticeList.length,
                                itemBuilder: (context, index) {
                                  final notice = noticeList[index];
                                  return ListTile(
                                    title: Text(notice.title),
                                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notice.modDate)),
                                    onTap: () {
                                      noticePopup(notice.id);
                                    },
                                  );
                                },
                            )
                        );
                      }
                    },
                  )
              )
            ]
        )
    );
  }

  Future<void> noticePopup(int id) async {
    Notice notice = await selectNotice(id);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(notice.title),
            content: Text(notice.content),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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

  Future<List<Notice>> getNoticeList() async {
    try {
      final url = Uri.parse('http://13.124.181.85:8080/v1/api/notice/list');

      final res = await http.get(url);

      if(res.statusCode != 200 ) {
        throw Exception('공지사항 조회 실패');
      }

      final List<dynamic> data = json.decode(utf8.decode(res.bodyBytes));

      return data.map((json) => Notice.fromJson(json)).toList();
    }catch (e) {
      throw Exception('공지사항 조회 실패');
    }
  }

  Future<Notice> selectNotice(int id) async {
    try {
      final url = Uri.parse('http://13.124.181.85:8080/v1/api/notice/detail').replace(
        queryParameters: {
          'id': id.toString()
        }
      );

      final res = await http.get(url);

      if(res.statusCode != 200 ) {
        throw Exception('공지사항 상세 조회 실패');
      }

      final dynamic data = json.decode(utf8.decode(res.bodyBytes));

      return Notice.fromJson(data);
    }catch (e) {
      print(e);
      throw Exception('공지사항 상세 조회 실패');
    }
  }
}