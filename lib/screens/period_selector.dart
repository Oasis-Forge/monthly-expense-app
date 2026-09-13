import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../providers/transaction_provider.dart';

/// Arrows around the selected period's label (PER-3), shared by Home and
/// Insights.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousPeriodTooltip,
            onPressed: provider.previousPeriod,
          ),
          // Long labels shrink to fit narrow screens.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                periodLabel(provider.period, l10n),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextPeriodTooltip,
            onPressed: provider.nextPeriod,
          ),
        ],
      ),
    );
  }
}
