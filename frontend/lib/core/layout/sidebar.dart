import 'package:flutter/material.dart';

import 'sidebar_menu_item.dart';
import 'sidebar_header.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF171923),
      child: const Column(
        children: [
          SidebarHeader(),
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
