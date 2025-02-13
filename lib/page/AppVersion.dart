import 'package:flutter/material.dart';

import '../layout/Header.dart';

class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Header(title: '앱 버전'),
        body: Center(child: Text('v Alpha 1.0'))
    );
  }


}