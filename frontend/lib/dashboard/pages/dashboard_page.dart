import 'package:flutter/material.dart';

import 'package:frontend/dashboard/widgets/dashboard_header.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DashboardHeader(),
    );
  }
}
