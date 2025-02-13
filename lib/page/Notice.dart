import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../layout/Header.dart';

class Notice extends StatelessWidget {
  const Notice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Header(title: '공지사항'),
        body: Center(child: Text('To Be Continue'))
    );
  }
}