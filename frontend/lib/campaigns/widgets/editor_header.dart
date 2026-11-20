import 'package:flutter/material.dart';

import '../models/campaign.dart';

class EditorHeader extends StatelessWidget {
  const EditorHeader({
    super.key,
    required this.campaign,
    required this.onBack,
    required this.onRefresh,
  });

  final Campaign? campaign;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back to campaigns',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                campaign?.name ?? 'Campaign',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                campaign == null
                    ? ''
                    : 'ID ${campaign!.id}  •  Alias ${campaign!.alias}  •  ${campaign!.state}',
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
