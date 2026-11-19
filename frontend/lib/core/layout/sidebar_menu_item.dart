import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SidebarMenuItem extends StatelessWidget {
  const SidebarMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    final isSelected = GoRouterState.of(context).uri.path == route;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blueAccent : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blueAccent : Colors.white70,
          ),
        ),
        onTap: () => context.go(route),
      ),
    );
  }
}
