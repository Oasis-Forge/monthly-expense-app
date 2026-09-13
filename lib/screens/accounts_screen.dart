import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/account.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'account_edit_screen.dart';
import 'transfer_screen.dart';

/// Accounts with today's balances (ACC-4), and the way to add accounts and
/// transfers.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final archived = provider.archivedAccounts;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: l10n.transferTooltip,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TransferScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addAccountTooltip,
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AccountEditScreen())),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          for (final account in provider.activeAccounts)
            _AccountTile(account: account),
          if (archived.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l10n.archivedHeader,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            for (final account in archived) _AccountTile(account: account),
          ],
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final balance = provider.accountBalance(account.id);

    return ListTile(
      leading: CircleAvatar(child: Icon(accountTypeIcon(account.type))),
      title: Text(account.label(l10n)),
      subtitle: Text(accountTypeLabel(account.type, l10n)),
      trailing: Text(
        currency.format(balance.toDouble()),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: balance.isNegative ? Colors.red : null,
        ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AccountEditScreen(editing: account)),
      ),
    );
  }
}
