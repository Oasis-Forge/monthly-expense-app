import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';

/// Chooses which account the period is shown for: one of them, or every one
/// (ACC-6). The view and the saved choice move together, so a relaunch opens
/// on the same account. Archived accounts are left out, since this is the
/// everyday round and their history is on the Accounts screen (ACC-5).
Future<void> pickAccountFilter(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final provider = context.read<TransactionProvider>();
  final settings = context.read<SettingsProvider>();
  final accounts = provider.activeAccounts;
  final chosen = provider.accountFilterId;
  final picked = await showModalBottomSheet<({String? id})>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: Icon(
              chosen == null
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            ),
            // A screen reader hears which one is chosen, not just the list.
            selected: chosen == null,
            title: Text(l10n.allAccountsFilter),
            onTap: () => Navigator.of(sheetContext).pop((id: null)),
          ),
          for (final account in accounts)
            ListTile(
              leading: Icon(
                chosen == account.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              selected: chosen == account.id,
              title: Text(account.label(l10n)),
              onTap: () => Navigator.of(sheetContext).pop((id: account.id)),
            ),
        ],
      ),
    ),
  );
  if (picked == null) return;
  provider.selectAccountFilter(picked.id);
  await settings.setAccountFilterId(picked.id);
}

/// Opens the account chooser from a toolbar. Shown only where there is more
/// than one account to choose between (ACC-6).
class AccountFilterAction extends StatelessWidget {
  const AccountFilterAction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    if (provider.activeAccounts.length < 2) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.account_balance_wallet_outlined),
      tooltip: l10n.accountLabel,
      onPressed: () => pickAccountFilter(context),
    );
  }
}

/// Names the account a screen is showing, and nothing at all while it is
/// showing every one (ACC-6). Only a narrowed screen has something to say, so
/// the usual case costs no room above a list — which is the whole reason the
/// summary card is a scrolling header in the first place (BAL-7).
class AccountFilterBanner extends StatelessWidget {
  const AccountFilterBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final id = provider.accountFilterId;
    if (id == null) return const SizedBox.shrink();
    final account = provider.accountById(id);
    if (account == null) return const SizedBox.shrink();
    return InkWell(
      onTap: () => pickAccountFilter(context),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 8, 4),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                account.label(l10n),
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: l10n.allAccountsFilter,
              visualDensity: VisualDensity.compact,
              onPressed: () async {
                final provider = context.read<TransactionProvider>();
                final settings = context.read<SettingsProvider>();
                provider.selectAccountFilter(null);
                await settings.setAccountFilterId(null);
              },
            ),
          ],
        ),
      ),
    );
  }
}
