import 'package:flutter/material.dart';

class CampaignsHeader extends StatelessWidget {
  const CampaignsHeader({
    super.key,
    required this.isLoading,
    required this.onRefresh,
    required this.onCreate,
  });

  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campaigns',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Manage live Keitaro campaigns and streams',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: isLoading ? null : onRefresh,
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: const Text('Create campaign'),
        ),
      ],
    );
  }
}
