import 'package:flutter/material.dart';

import '../../campaigns/models/campaign_options.dart';
import '../../core/widgets/search_field.dart';
import 'offer_card.dart';

class OffersTable extends StatefulWidget {
  const OffersTable({super.key, required this.offers});

  final List<OptionItem> offers;

  @override
  State<OffersTable> createState() => _OffersTableState();
}

class _OffersTableState extends State<OffersTable> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.offers.where((offer) {
      final query = _query.toLowerCase();
      return offer.name.toLowerCase().contains(query) ||
          offer.id.toString().contains(query);
    }).toList();

    return Column(
      children: [
        SearchField(
          controller: _searchController,
          hintText: 'Search by offer name or ID',
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171923),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No offers match this search.',
                      style: TextStyle(color: Colors.white60),
                    ),
                  )
                : SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Offer')),
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('State')),
                        ],
                        rows: filtered.map((offer) {
                          return OfferCard(offer: offer);
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
