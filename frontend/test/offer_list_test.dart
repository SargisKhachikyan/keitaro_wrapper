import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/campaigns/models/campaign_options.dart';
import 'package:frontend/campaigns/models/stream.dart';
import 'package:frontend/campaigns/widgets/offer_list.dart';

void main() {
  testWidgets('explains when there are no offers left to add', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OfferList(
            streamId: 10,
            streamOffers: const [
              StreamOffer(offerId: 1, share: 100, state: 'active'),
            ],
            availableOffers: const [OptionItem(id: 1, name: 'Existing offer')],
          ),
        ),
      ),
    );

    expect(find.text('No other offers available'), findsOneWidget);
  });

  testWidgets('opens the add-offer menu when an eligible offer exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OfferList(
            streamId: 10,
            streamOffers: const [
              StreamOffer(offerId: 1, share: 100, state: 'active'),
            ],
            availableOffers: const [
              OptionItem(id: 1, name: 'Existing offer'),
              OptionItem(id: 2, name: 'New offer'),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<OptionItem>));
    await tester.pumpAndSettle();

    expect(find.text('New offer'), findsOneWidget);
  });
}
