import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/campaign_editor_bloc.dart';
import '../bloc/campaign_editor_event.dart';
import '../models/campaign_options.dart';
import '../models/stream.dart';
import 'offer_item.dart';

class OfferList extends StatelessWidget {
  const OfferList({
    super.key,
    required this.streamId,
    required this.streamOffers,
    required this.availableOffers,
  });

  final int streamId;
  final List<StreamOffer> streamOffers;
  final List<OptionItem> availableOffers;

  @override
  Widget build(BuildContext context) {
    final names = {for (final offer in availableOffers) offer.id: offer.name};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (streamOffers.isEmpty)
          const Text(
            'No offers configured for this stream.',
            style: TextStyle(color: Colors.white60),
          )
        else
          Column(
            children: streamOffers.map((offer) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OfferItem(
                  streamId: streamId,
                  offer: offer,
                  name: names[offer.offerId] ?? 'Offer ID ${offer.offerId}',
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        _OfferAddField(
          streamId: streamId,
          streamOffers: streamOffers,
          offers: availableOffers,
        ),
      ],
    );
  }
}

class _OfferAddField extends StatelessWidget {
  const _OfferAddField({
    required this.streamId,
    required this.streamOffers,
    required this.offers,
  });

  final int streamId;
  final List<StreamOffer> streamOffers;
  final List<OptionItem> offers;

  @override
  Widget build(BuildContext context) {
    final choices = offers.where((item) {
      return !streamOffers.any((offer) => offer.offerId == item.id);
    }).toList();

    return DropdownButtonFormField<OptionItem>(
      initialValue: null,
      decoration: const InputDecoration(
        labelText: 'Add offer',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: choices
          .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
          .toList(),
      onChanged: choices.isEmpty
          ? null
          : (item) {
              if (item == null) return;
              _addOffer(context, item);
            },
    );
  }

  void _addOffer(BuildContext context, OptionItem item) {
    context.read<CampaignEditorBloc>().add(
      CampaignEditorOfferAdded(
        streamId: streamId,
        offer: StreamOffer(offerId: item.id, share: 100, state: 'active'),
      ),
    );
  }
}
