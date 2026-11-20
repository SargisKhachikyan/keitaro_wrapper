import 'package:flutter/material.dart';

import '../../campaigns/models/campaign_options.dart';

class OfferCard extends DataRow {
  OfferCard({super.key, required OptionItem offer})
    : super(
        cells: [
          DataCell(Text(offer.name)),
          DataCell(Text(offer.id.toString())),
          DataCell(_OfferState(state: offer.state)),
        ],
      );
}

class _OfferState extends StatelessWidget {
  const _OfferState({required this.state});

  final String? state;

  @override
  Widget build(BuildContext context) {
    final name = state?.isEmpty != false ? 'unknown' : state!;
    final active = state == 'active';
    return Chip(
      label: Text(name),
      labelStyle: TextStyle(
        color: active ? Colors.greenAccent : Colors.orangeAccent,
      ),
      side: BorderSide.none,
    );
  }
}
