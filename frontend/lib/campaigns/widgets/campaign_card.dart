import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/campaign.dart';

class CampaignCard extends DataRow {
  CampaignCard({super.key, required Campaign campaign})
    : super(
        cells: [
          DataCell(Text(campaign.name)),
          DataCell(Text(campaign.id.toString())),
          DataCell(Text(campaign.alias)),
          DataCell(_StateBadge(state: campaign.state)),
          DataCell(Text(campaign.updatedAt)),
          DataCell(
            Builder(
              builder: (context) => IconButton(
                tooltip: 'Open campaign',
                onPressed: () => context.go('/campaigns/${campaign.id}'),
                icon: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ],
      );
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});

  final String state;

  @override
  Widget build(BuildContext context) {
    final active = state == 'active';
    return Chip(
      label: Text(state.isEmpty ? 'unknown' : state),
      labelStyle: TextStyle(
        color: active ? Colors.greenAccent : Colors.orangeAccent,
        fontSize: 12,
      ),
      backgroundColor: active
          ? Colors.green.withValues(alpha: 0.12)
          : Colors.orange.withValues(alpha: 0.12),
      side: BorderSide.none,
    );
  }
}
