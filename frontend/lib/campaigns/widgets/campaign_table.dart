import 'package:flutter/material.dart';

import '../models/campaign.dart';
import '../../../core/widgets/search_field.dart';
import 'campaign_card.dart';

class CampaignTable extends StatefulWidget {
  const CampaignTable({super.key, required this.campaigns});

  final List<Campaign> campaigns;

  @override
  State<CampaignTable> createState() => _CampaignTableState();
}

class _CampaignTableState extends State<CampaignTable> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.campaigns.where((campaign) {
      final query = _query.toLowerCase();
      return campaign.name.toLowerCase().contains(query) ||
          campaign.alias.toLowerCase().contains(query) ||
          campaign.id.toString().contains(query);
    }).toList();

    return Column(
      children: [
        SearchField(
          controller: _searchController,
          hintText: 'Search by name, alias, or ID',
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
                      'No campaigns match this search.',
                      style: TextStyle(color: Colors.white60),
                    ),
                  )
                : SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: _CampaignDataTable(campaigns: filtered),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _CampaignDataTable extends StatelessWidget {
  const _CampaignDataTable({required this.campaigns});

  final List<Campaign> campaigns;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      showCheckboxColumn: false,
      columns: const [
        DataColumn(label: Text('Campaign')),
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Alias')),
        DataColumn(label: Text('State')),
        DataColumn(label: Text('Updated')),
        DataColumn(label: Text('')),
      ],
      rows: campaigns.map((campaign) {
        return CampaignCard(campaign: campaign);
      }).toList(),
    );
  }
}
