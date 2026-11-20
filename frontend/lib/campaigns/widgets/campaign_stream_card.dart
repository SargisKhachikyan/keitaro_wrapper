import 'package:flutter/material.dart';

import '../models/campaign_options.dart';
import '../models/stream.dart';
import 'offer_list.dart';
import 'stream_filters.dart';
import 'stream_header.dart';

class CampaignStreamCard extends StatelessWidget {
  const CampaignStreamCard({
    super.key,
    required this.stream,
    required this.offers,
  });

  final CampaignStream stream;
  final List<OptionItem> offers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171923),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamHeader(stream: stream),
          StreamFilters(filters: stream.filters),
          const SizedBox(height: 16),
          OfferList(
            streamId: stream.id,
            streamOffers: stream.offers,
            availableOffers: offers,
          ),
        ],
      ),
    );
  }
}
