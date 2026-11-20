import 'package:flutter/material.dart';

import '../models/campaign_options.dart';
import '../models/stream.dart';
import 'campaign_stream_card.dart';

class StreamList extends StatelessWidget {
  const StreamList({super.key, required this.streams, required this.offers});

  final List<CampaignStream> streams;
  final List<OptionItem> offers;

  @override
  Widget build(BuildContext context) {
    if (streams.isEmpty) {
      return const Center(
        child: Text(
          'This campaign has no streams.',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }
    return ListView.separated(
      itemCount: streams.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final stream = streams[index];
        return CampaignStreamCard(stream: stream, offers: offers);
      },
    );
  }
}
