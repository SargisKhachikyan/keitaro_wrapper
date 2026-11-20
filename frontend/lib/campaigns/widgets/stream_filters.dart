import 'package:flutter/material.dart';

import '../models/stream.dart';

class StreamFilters extends StatelessWidget {
  const StreamFilters({super.key, required this.filters});

  final List<StreamFilter> filters;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filters.map((filter) {
          return Chip(
            label: Text(
              '${filter.name}: ${filter.mode} '
              '${filter.payload.join(', ')}',
            ),
          );
        }).toList(),
      ),
    );
  }
}
