import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../app/theme/again_tokens.dart';

class AgainPrimaryNavigation extends StatelessWidget {
  const AgainPrimaryNavigation({super.key, required this.selectedIndex});

  final int selectedIndex;

  static const paths = [
    AppRoutes.homePath,
    AppRoutes.worldMapPath,
    AppRoutes.storySquarePath,
    AppRoutes.humaConversationPath,
    AppRoutes.profilePath,
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AgainColors.night900.withValues(alpha: .97),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AgainColors.gold400.withValues(alpha: .45)),
      ),
      child: NavigationBar(
        height: 70,
        backgroundColor: Colors.transparent,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(paths[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Harita',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum_rounded),
            label: 'Meydan',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Hüma',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    ),
  );
}
