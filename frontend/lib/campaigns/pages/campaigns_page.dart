import 'package:flutter/material.dart';

import 'package:frontend/campaigns/widgets/campaigns_header.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CampaignsHeader(),
    );
  }
}
