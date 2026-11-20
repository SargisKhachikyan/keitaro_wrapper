import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../bloc/campaign_editor_bloc.dart';

class CampaignEditorRouteGuard {
  CampaignEditorBloc? _editorBloc;

  void register(CampaignEditorBloc bloc) {
    _editorBloc = bloc;
  }

  void unregister(CampaignEditorBloc bloc) {
    if (identical(_editorBloc, bloc)) _editorBloc = null;
  }

  Future<bool> onExit(BuildContext context, GoRouterState state) async {
    final bloc = _editorBloc;
    if (bloc == null || bloc.isClosed) return true;
    final canExit = await confirmDiscard(context, bloc.state.hasUnsavedChanges);
    if (canExit) unregister(bloc);
    return canExit;
  }

  Future<bool> confirmDiscard(
    BuildContext context,
    bool hasUnsavedChanges,
  ) async {
    if (!hasUnsavedChanges) return true;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Discard unsaved changes'),
            content: const Text(
              'This campaign has offer changes that have not been saved. '
              'Discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

final campaignEditorRouteGuard = CampaignEditorRouteGuard();
