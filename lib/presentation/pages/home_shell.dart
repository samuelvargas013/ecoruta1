import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/user_entity.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'report_form_page.dart';
import 'reports_list_page.dart';

/// Contenedor principal con barra de navegación inferior.
class HomeShell extends StatefulWidget {
  final UserEntity user;
  const HomeShell({super.key, required this.user});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      MapPage(user: widget.user),
      ReportsListPage(user: widget.user),
      ProfilePage(uid: widget.user.uid),
    ];
    const titles = [AppStrings.map, AppStrings.reports, AppStrings.profile];

    return Scaffold(
      appBar: AppBar(title: Text('${AppStrings.appName} · ${titles[_index]}')),
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => ReportFormPage(user: widget.user)),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: AppStrings.map),
          NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: AppStrings.reports),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: AppStrings.profile),
        ],
      ),
    );
  }
}
