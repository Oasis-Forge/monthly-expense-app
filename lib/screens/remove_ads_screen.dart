import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/ads_provider.dart';
import '../services/purchase_service.dart';

/// The only place the app sells anything: "Remove ads", and Plus as a note
/// that it is coming (PAY-1, PAY-3, PAY-7).
///
/// There is no countdown, no trial, and nothing is asked twice. Every
/// feature in the app works whether or not anything here is bought (PAY-4).
class RemoveAdsScreen extends StatelessWidget {
  const RemoveAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ads = context.watch<AdsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.removeAdsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RemoveAds(ads: ads),
          const SizedBox(height: 16),
          const _Plus(),
          const SizedBox(height: 24),
          // PAY-4: nothing that works today ever moves behind a payment.
          Text(
            l10n.payNothingWithheld,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RemoveAds extends StatelessWidget {
  const _RemoveAds({required this.ads});

  final AdsProvider ads;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final price = ads.price;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.block_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.removeAdsTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.removeAdsBody),
            const SizedBox(height: 16),
            switch (ads.stage) {
              // Already bought, here or on another device (PAY-1, PAY-5).
              PurchaseStage.owned => Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.removeAdsOwned)),
                ],
              ),
              // PAY-8: nothing changes until the store settles it.
              PurchaseStage.pending => Row(
                children: [
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.removeAdsPending)),
                ],
              ),
              PurchaseStage.checking => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              ),
              // Nothing to buy, so nothing is offered (PAY-3): no button
              // that would only fail.
              PurchaseStage.unavailable => Text(
                l10n.removeAdsUnavailable,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              PurchaseStage.offered => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: ads.buyRemoveAds,
                    // PAY-6: the price comes from the store, in the buyer's
                    // own currency, never from the app's currency setting.
                    child: Text(
                      price == null
                          ? l10n.removeAdsTitle
                          : l10n.removeAdsBuyButton(price),
                    ),
                  ),
                ],
              ),
            },
            if (ads.stage != PurchaseStage.owned &&
                ads.stage != PurchaseStage.checking)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  // PAY-5: beside the price, always, so a reinstall or a
                  // family-shared purchase needs no support request.
                  onPressed: ads.restorePurchases,
                  child: Text(l10n.restorePurchasesButton),
                ),
              ),
            if (ads.lastError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.removeAdsFailed,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Plus, named and described but not sold: the bank connection it would buy
/// doesn't work yet, and nothing is sold before it exists (PAY-3).
class _Plus extends StatelessWidget {
  const _Plus();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.plusTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Where the price would be, and all that goes there: no price
            // and no button, because there is nothing here to buy (PAY-3).
            // On its own line, so a long translation has the width.
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Chip(
                label: Text(l10n.plusComingSoon),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.plusBody),
          ],
        ),
      ),
    );
  }
}
