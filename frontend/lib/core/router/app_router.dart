import 'package:frontend/campaigns/pages/campaigns_page.dart';
import 'package:frontend/core/layout/app_layout.dart';
import 'package:frontend/dashboard/pages/dashboard_page.dart';
import 'package:frontend/offers/pages/offers_page.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppLayout(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
        GoRoute(
          path: '/campaigns',
          builder: (context, state) => const CampaignsPage(),
        ),
        GoRoute(
          path: '/offers',
          builder: (context, state) => const OffersPage(),
        ),
      ],
    ),
  ],
);
