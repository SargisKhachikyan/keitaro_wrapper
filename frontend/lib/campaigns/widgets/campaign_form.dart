import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/campaign_options.dart';
import 'option_dropdown.dart';

class CampaignForm extends StatelessWidget {
  const CampaignForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.geoController,
    required this.options,
    required this.onDomainChanged,
    required this.onGroupChanged,
    required this.onTrafficChanged,
    required this.onOfferChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController geoController;
  final CampaignOptions options;
  final ValueChanged<OptionItem?> onDomainChanged;
  final ValueChanged<OptionItem?> onGroupChanged;
  final ValueChanged<OptionItem?> onTrafficChanged;
  final ValueChanged<OptionItem?> onOfferChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NameField(controller: nameController),
            const SizedBox(height: 16),
            _GeoField(controller: geoController),
            const SizedBox(height: 8),
            OptionDropdown(
              label: 'Keitaro offer',
              value: options.offers.isEmpty ? null : options.offers.first,
              items: options.offers,
              onChanged: onOfferChanged,
            ),
            const SizedBox(height: 16),
            OptionDropdown(
              label: 'Domain',
              value: options.domains.isEmpty ? null : options.domains.first,
              items: options.domains,
              onChanged: onDomainChanged,
            ),
            const SizedBox(height: 16),
            OptionDropdown(
              label: 'Campaign group',
              value: options.groups.isEmpty ? null : options.groups.first,
              items: options.groups,
              onChanged: onGroupChanged,
            ),
            const SizedBox(height: 16),
            OptionDropdown(
              label: 'Traffic source',
              value: options.trafficSources.isEmpty
                  ? null
                  : options.trafficSources.first,
              items: options.trafficSources,
              onChanged: onTrafficChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Campaign name',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Enter a campaign name'
          : null,
    );
  }
}

class _GeoField extends StatelessWidget {
  const _GeoField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: 2,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
        _UppercaseFormatter(),
      ],
      decoration: const InputDecoration(
        labelText: 'GEO country code',
        hintText: 'US',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || !RegExp(r'^[A-Za-z]{2}$').hasMatch(value)) {
          return 'Enter a 2-letter country code';
        }
        return null;
      },
    );
  }
}

class _UppercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: TextSelection.collapsed(offset: newValue.text.length),
    );
  }
}
