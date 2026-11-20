import '../../campaigns/models/campaign_options.dart';
import '../../campaigns/repository/campaigns_repository.dart';

class OffersRepository {
  OffersRepository(this._campaignsRepository);

  final CampaignsRepository _campaignsRepository;

  Future<List<OptionItem>> getOffers() {
    return _campaignsRepository.getOffers();
  }
}
