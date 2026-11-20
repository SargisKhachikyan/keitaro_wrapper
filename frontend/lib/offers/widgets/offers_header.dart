import 'package:flutter/material.dart';

class OffersHeader extends StatelessWidget {
  const OffersHeader({
    super.key,
    required this.isLoading,
    required this.onRefresh,
  });

  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offers',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Offers available from the connected Keitaro instance',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: isLoading ? null : onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
