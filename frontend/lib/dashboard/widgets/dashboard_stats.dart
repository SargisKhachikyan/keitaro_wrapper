import 'package:flutter/material.dart';

import 'stat_card.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({
    super.key,
    required this.campaignCount,
    required this.activeCampaignCount,
    required this.offerCount,
  });

  final int campaignCount;
  final int activeCampaignCount;
  final int offerCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        StatCard(
          title: 'Campaigns',
          value: campaignCount.toString(),
          icon: Icons.campaign_outlined,
        ),
        StatCard(
          title: 'Active campaigns',
          value: activeCampaignCount.toString(),
          icon: Icons.online_prediction_outlined,
        ),
        StatCard(
          title: 'Available offers',
          value: offerCount.toString(),
          icon: Icons.local_offer_outlined,
        ),
      ],
    );
  }
}
