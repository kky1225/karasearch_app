import 'package:flutter/material.dart';
import 'package:karasearch/layout/Header.dart';
import 'package:karasearch/layout/Bottom.dart';
import 'package:karasearch/page/AppVersion.dart';
import 'package:karasearch/page/Bookmark.dart';
import 'package:karasearch/page/New.dart';
import 'package:karasearch/page/NoticeList.dart';
import 'package:karasearch/page/Popular.dart';
import 'package:karasearch/page/Search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KaraSearch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Screen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  int currentPage = 0;

  final List<Widget> pages = [
    Search(),
    New(),
    Popular(),
    Bookmark()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'KaraSearch'),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 130,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.blueAccent),
                child: Text(
                  '메뉴',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.notification_important),
              title: Text('공지사항'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => NoticeList()));
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('앱 버전'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => AppVersion()));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: pages[currentPage]
      ),
      bottomNavigationBar: Bottom(
        currentPage: currentPage,
        onChange: (index) {
          setState(() {
            currentPage = index;
          });
        },
      ),
    );
  }
}