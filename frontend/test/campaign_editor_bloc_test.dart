import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/campaigns/bloc/campaign_editor_bloc.dart';
import 'package:frontend/campaigns/bloc/campaign_editor_event.dart';
import 'package:frontend/campaigns/bloc/campaign_editor_state.dart';
import 'package:frontend/campaigns/models/campaign.dart';
import 'package:frontend/campaigns/models/campaign_options.dart';
import 'package:frontend/campaigns/models/stream.dart';
import 'package:frontend/campaigns/repository/campaigns_repository.dart';
import 'package:frontend/core/api/api_client.dart';

void main() {
  test(
    'saving one changed stream leaves other changed streams dirty',
    () async {
      final repository = _FakeCampaignsRepository();
      final bloc = CampaignEditorBloc(repository, 1);
      addTearDown(bloc.close);

      final loaded = bloc.stream.firstWhere(
        (state) => state.status == CampaignEditorStatus.loaded,
      );
      bloc.add(const CampaignEditorLoadRequested(1));
      await loaded;

      final firstChanged = bloc.stream.firstWhere(
        (state) => state.dirtyStreamIds.contains(10),
      );
      bloc.add(
        const CampaignEditorShareChanged(streamId: 10, offerId: 100, share: 70),
      );
      await firstChanged;

      final bothChanged = bloc.stream.firstWhere(
        (state) => state.dirtyStreamIds.containsAll({10, 20}),
      );
      bloc.add(
        const CampaignEditorShareChanged(streamId: 20, offerId: 200, share: 60),
      );
      await bothChanged;

      final firstSaved = bloc.stream.firstWhere(
        (state) => state.status == CampaignEditorStatus.success,
      );
      bloc.add(const CampaignEditorSaveRequested(10));
      final stateAfterSave = await firstSaved;

      expect(repository.savedStreamIds, [10]);
      expect(stateAfterSave.dirtyStreamIds, {20});
      expect(stateAfterSave.hasUnsavedChanges, isTrue);

      final allSaved = bloc.stream.firstWhere(
        (state) =>
            state.status == CampaignEditorStatus.success &&
            !state.hasUnsavedChanges,
      );
      bloc.add(const CampaignEditorSaveRequested(20));
      final stateAfterAllSaved = await allSaved;

      expect(repository.savedStreamIds, [10, 20]);
      expect(stateAfterAllSaved.dirtyStreamIds, isEmpty);
    },
  );
}

class _FakeCampaignsRepository extends CampaignsRepository {
  _FakeCampaignsRepository() : super(ApiClient());

  final List<int> savedStreamIds = [];

  @override
  Future<List<Campaign>> getCampaigns() async => const [
    Campaign(
      id: 1,
      name: 'Test',
      alias: 'test',
      state: 'active',
      groupId: 1,
      domainId: 1,
      trafficSourceId: 1,
      updatedAt: '',
    ),
  ];

  @override
  Future<CampaignOptions> getOptions() async => const CampaignOptions(
    groups: [],
    domains: [],
    trafficSources: [],
    offers: [],
  );

  @override
  Future<List<CampaignStream>> getStreams(int campaignId) async => [
    _stream(10, 100),
    _stream(20, 200),
  ];

  @override
  Future<void> saveStreamOffers(int streamId, List<StreamOffer> offers) async {
    savedStreamIds.add(streamId);
  }

  CampaignStream _stream(int streamId, int offerId) => CampaignStream(
    id: streamId,
    name: 'Stream $streamId',
    type: 'regular',
    schema: 'landings',
    actionType: 'http',
    actionPayload: null,
    filters: const [],
    offers: [StreamOffer(offerId: offerId, share: 100, state: 'active')],
    state: 'active',
  );
}
