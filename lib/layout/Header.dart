import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Colors.blueAccent,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        color: Colors.white
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}