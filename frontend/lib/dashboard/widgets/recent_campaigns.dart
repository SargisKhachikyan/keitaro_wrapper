import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../campaigns/models/campaign.dart';

class RecentCampaigns extends StatelessWidget {
  const RecentCampaigns({super.key, required this.campaigns});

  final List<Campaign> campaigns;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171923),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Recent campaigns',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          if (campaigns.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                'No campaigns are available.',
                style: TextStyle(color: Colors.white60),
              ),
            )
          else
            for (final campaign in campaigns)
              Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(campaign.name),
                  subtitle: Text('ID ${campaign.id}  •  ${campaign.alias}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/campaigns/${campaign.id}'),
                ),
              ),
        ],
      ),
    );
  }
}
