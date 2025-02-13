import 'package:flutter/material.dart';

class Bottom extends StatelessWidget {
  const Bottom({super.key, required this.currentPage, required this.onChange});

  final int currentPage;
  final Function(int) onChange;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: onChange,
      selectedIndex: currentPage,
      destinations: const [
        NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search),
            label: '노래 검색'
        ),
        NavigationDestination(
            selectedIcon: Icon(Icons.fiber_new_outlined),
            icon: Icon(Icons.fiber_new_outlined),
            label: '이달의 신곡'
        ),
        NavigationDestination(
            selectedIcon: Icon(Icons.thumb_up),
            icon: Icon(Icons.thumb_up),
            label: '인기차트'
        ),
        NavigationDestination(
            selectedIcon: Icon(Icons.grade),
            icon: Icon(Icons.grade),
            label: '즐겨찾기'
        )
      ],
    );
  }
}