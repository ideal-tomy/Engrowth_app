import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  int _locationToIndex(String location) {
    if (location.startsWith('/words')) return 0;
    if (location.startsWith('/sentences')) return 1;
    if (location.startsWith('/study')) return 2;
    if (location.startsWith('/progress')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        final target = switch (index) {
          0 => '/words',
          1 => '/sentences',
          2 => '/study',
          3 => '/progress',
          _ => '/words',
        };
        if (location != target) {
          context.go(target);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: '単語',
        ),
        NavigationDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(Icons.article),
          label: '例文',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: '学習',
        ),
        NavigationDestination(
          icon: Icon(Icons.trending_up_outlined),
          selectedIcon: Icon(Icons.trending_up),
          label: '進捗',
        ),
      ],
    );
  }
}
