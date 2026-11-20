import '../../core/api/api_client.dart';
import '../models/campaign.dart';
import '../models/campaign_options.dart';
import '../models/stream.dart';

class CampaignCreationPartialFailure implements Exception {
  const CampaignCreationPartialFailure({
    required this.campaignId,
    required this.operation,
    required this.message,
  });

  final int campaignId;
  final String operation;
  final String message;

  @override
  String toString() =>
      'Campaign $campaignId was created, but $operation failed: $message';
}

class CampaignsRepository {
  CampaignsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CampaignOptions> getOptions() async {
    final json = await _apiClient.getJson('/keitaro/options');
    return CampaignOptions.fromJson(json);
  }

  Future<List<Campaign>> getCampaigns() async {
    final json = await _apiClient.getJson('/keitaro/campaigns');
    final campaigns = json['campaigns'];
    if (campaigns is! List) return const [];
    return campaigns.whereType<Map>().map((item) {
      return Campaign.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<List<CampaignStream>> getStreams(int campaignId) async {
    final json = await _apiClient.getJson(
      '/keitaro/campaigns/$campaignId/streams',
    );
    final streams = json['streams'];
    if (streams is! List) return const [];
    return streams.whereType<Map>().map((item) {
      return CampaignStream.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<CampaignStream> getStream(int streamId) async {
    final json = await _apiClient.getJson('/keitaro/streams/$streamId');
    final stream = json['stream'];
    if (stream is! Map) {
      throw const ApiException('The stream response was missing stream data.');
    }
    return CampaignStream.fromJson(Map<String, dynamic>.from(stream));
  }

  Future<void> saveStreamOffers(int streamId, List<StreamOffer> offers) async {
    await _apiClient.putJson('/keitaro/streams/$streamId/offers', {
      'offers': offers.map((offer) => offer.toJson()).toList(),
    });
  }

  Future<int> createCampaignWithStreams({
    required String name,
    required String geo,
    required int domainId,
    required int groupId,
    required int trafficSourceId,
    required int offerId,
  }) async {
    final campaignResponse = await _apiClient.postJson('/keitaro/campaigns', {
      'name': name,
      'domain_id': domainId,
      'group_id': groupId,
      'traffic_source_id': trafficSourceId,
    });
    final campaign = campaignResponse['campaign'];
    if (campaign is! Map) {
      throw const ApiException('Campaign creation returned no campaign data.');
    }
    final campaignId = _int(Map<String, dynamic>.from(campaign)['id']);
    if (campaignId == 0) {
      throw const ApiException('Campaign creation returned no campaign ID.');
    }

    try {
      await _apiClient.postJson('/keitaro/campaigns/$campaignId/streams', {
        'name': '$name - $geo',
        'type': 'regular',
        'schema': 'redirect',
        'action_type': 'http',
        'action_options': {'url': 'https://www.google.com'},
        'filters': [
          {
            'name': 'country',
            'mode': 'accept',
            'payload': [geo],
          },
        ],
        'offers': [],
      });
    } catch (error) {
      throw CampaignCreationPartialFailure(
        campaignId: campaignId,
        operation: 'country stream creation',
        message: error.toString(),
      );
    }

    try {
      await _apiClient.postJson('/keitaro/campaigns/$campaignId/streams', {
        'name': '$name - Offer',
        'type': 'default',
        'schema': 'landings',
        'action_type': 'http',
        'filters': [],
        'offers': [
          {'offer_id': offerId, 'share': 100, 'state': 'active'},
        ],
      });
    } catch (error) {
      throw CampaignCreationPartialFailure(
        campaignId: campaignId,
        operation: 'offer stream creation',
        message: error.toString(),
      );
    }

    return campaignId;
  }

  Future<List<OptionItem>> getOffers() async {
    final options = await getOptions();
    return options.offers;
  }
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
