import 'package:flutter/material.dart';

import '../models/campaign_options.dart';

class OptionDropdown extends StatelessWidget {
  const OptionDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final OptionItem? value;
  final List<OptionItem> items;
  final ValueChanged<OptionItem?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<OptionItem>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
          .toList(),
      onChanged: items.isEmpty ? null : onChanged,
    );
  }
}
