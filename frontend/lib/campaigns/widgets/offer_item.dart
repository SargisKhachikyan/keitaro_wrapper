import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/campaign_editor_bloc.dart';
import '../bloc/campaign_editor_event.dart';
import '../models/stream.dart';

class OfferItem extends StatelessWidget {
  const OfferItem({
    super.key,
    required this.streamId,
    required this.offer,
    required this.name,
  });

  final int streamId;
  final StreamOffer offer;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Offer ID ${offer.offerId}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: TextFormField(
              initialValue: offer.share.toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Share %',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => _changeShare(context, value),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Remove offer',
            onPressed: () => _confirmRemove(context),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  void _changeShare(BuildContext context, String value) {
    final share = int.tryParse(value);
    if (share == null) return;
    context.read<CampaignEditorBloc>().add(
      CampaignEditorShareChanged(
        streamId: streamId,
        offerId: offer.offerId,
        share: share.clamp(0, 100).toInt(),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove offer'),
        content: Text('Remove $name from this stream?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CampaignEditorBloc>().add(
        CampaignEditorOfferRemoved(streamId: streamId, offerId: offer.offerId),
      );
    }
  }
}
