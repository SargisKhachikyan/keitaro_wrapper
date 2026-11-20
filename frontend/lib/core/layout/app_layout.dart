import 'package:flutter/material.dart';

import 'sidebar.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final sidebarWidth = width < 900 ? 200.0 : 240.0;
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: sidebarWidth, child: const Sidebar()),
          Expanded(child: child),
        ],
      ),
    );
  }
}
