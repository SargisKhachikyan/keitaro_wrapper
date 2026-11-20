import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/campaign_editor_bloc.dart';
import '../bloc/campaign_editor_event.dart';
import '../bloc/campaign_editor_state.dart';
import '../models/stream.dart';

class StreamHeader extends StatelessWidget {
  const StreamHeader({super.key, required this.stream});

  final CampaignStream stream;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stream.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stream ID ${stream.id}  •  ${stream.type}  •  ${stream.schema}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
        BlocBuilder<CampaignEditorBloc, CampaignEditorState>(
          builder: (context, state) {
            final isSaving = state.status == CampaignEditorStatus.saving;
            return FilledButton.icon(
              onPressed: isSaving
                  ? null
                  : () => context.read<CampaignEditorBloc>().add(
                      CampaignEditorSaveRequested(stream.id),
                    ),
              icon: const Icon(Icons.save_outlined),
              label: Text(isSaving ? 'Saving...' : 'Save offers'),
            );
          },
        ),
      ],
    );
  }
}
