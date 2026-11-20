import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/campaigns_bloc.dart';
import '../bloc/campaigns_event.dart';
import '../bloc/campaigns_state.dart';
import '../models/campaign_options.dart';
import 'campaign_form.dart';

class CampaignCreateDialog extends StatefulWidget {
  const CampaignCreateDialog({super.key, required this.options});

  final CampaignOptions options;

  @override
  State<CampaignCreateDialog> createState() => _CampaignCreateDialogState();
}

class _CampaignCreateDialogState extends State<CampaignCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _geoController = TextEditingController();
  OptionItem? _domain;
  OptionItem? _group;
  OptionItem? _trafficSource;
  OptionItem? _offer;

  @override
  void initState() {
    super.initState();
    _domain = widget.options.domains.isEmpty
        ? null
        : widget.options.domains.first;
    _group = widget.options.groups.isEmpty ? null : widget.options.groups.first;
    _trafficSource = widget.options.trafficSources.isEmpty
        ? null
        : widget.options.trafficSources.first;
    _offer = widget.options.offers.isEmpty ? null : widget.options.offers.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _geoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CampaignsBloc, CampaignsState>(
      listener: (context, state) {
        if (state.status == CampaignsStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        title: const Text('Create campaign'),
        content: SizedBox(
          width: 520,
          child: CampaignForm(
            formKey: _formKey,
            nameController: _nameController,
            geoController: _geoController,
            options: widget.options,
            onDomainChanged: (value) => setState(() => _domain = value),
            onGroupChanged: (value) => setState(() => _group = value),
            onTrafficChanged: (value) => setState(() => _trafficSource = value),
            onOfferChanged: (value) => setState(() => _offer = value),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<CampaignsBloc, CampaignsState>(
            builder: (context, state) {
              final isCreating = state.status == CampaignsStatus.creating;
              return FilledButton(
                onPressed: isCreating ? null : _submit,
                child: isCreating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_domain == null ||
        _group == null ||
        _trafficSource == null ||
        _offer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select every campaign option.')),
      );
      return;
    }
    context.read<CampaignsBloc>().add(
      CampaignCreationRequested(
        name: _nameController.text.trim(),
        geo: _geoController.text.trim().toUpperCase(),
        domainId: _domain!.id,
        groupId: _group!.id,
        trafficSourceId: _trafficSource!.id,
        offerId: _offer!.id,
      ),
    );
  }
}
