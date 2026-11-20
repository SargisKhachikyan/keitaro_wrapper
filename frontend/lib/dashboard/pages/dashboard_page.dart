import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../campaigns/repository/campaigns_repository.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

import 'package:frontend/dashboard/widgets/dashboard_header.dart';

import '../widgets/dashboard_stats.dart';
import '../widgets/recent_campaigns.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DashboardBloc(context.read<CampaignsRepository>())
            ..add(const DashboardLoadRequested()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state.status == DashboardStatus.loading ||
            state.status == DashboardStatus.initial) {
          return const LoadingView();
        }
        if (state.status == DashboardStatus.failure) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: ErrorView(
              message: state.message ?? 'Could not load dashboard data.',
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(
                onRefresh: () => context.read<DashboardBloc>().add(
                  const DashboardLoadRequested(),
                ),
              ),
              const SizedBox(height: 32),
              DashboardStats(
                campaignCount: state.campaigns.length,
                activeCampaignCount: state.campaigns
                    .where((campaign) => campaign.state == 'active')
                    .length,
                offerCount: state.options?.offers.length ?? 0,
              ),
              const SizedBox(height: 32),
              RecentCampaigns(campaigns: state.campaigns.take(8).toList()),
            ],
          ),
        );
      },
    );
  }
}
