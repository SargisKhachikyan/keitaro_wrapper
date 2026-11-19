import 'package:flutter/material.dart';

import 'sidebar_menu_item.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF171923),
      child: const Column(
        children: [
          SizedBox(height: 32),
          Text(
            'KEITARO WRAPPER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 40),
          SidebarMenuItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            route: '/',
          ),
          SidebarMenuItem(
            icon: Icons.campaign_outlined,
            title: 'Campaigns',
            route: '/campaigns',
          ),
          SidebarMenuItem(
            icon: Icons.local_offer_outlined,
            title: 'Offers',
            route: '/offers',
          ),
        ],
      ),
    );
  }
}
