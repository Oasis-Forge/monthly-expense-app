import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/money.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';

const List<Color> _chartColors = [
  Color(0xFF6C5CE7),
  Color(0xFF00B894),
  Color(0xFFE17055),
  Color(0xFF0984E3),
  Color(0xFFFDCB6E),
  Color(0xFFD63031),
  Color(0xFF00CEC9),
  Color(0xFFE84393),
  Color(0xFF636E72),
  Color(0xFFA29BFE),
];

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final byCategory = provider.expenseByCategory;
    final total = byCategory.values.fold(Money.zero, (a, b) => a + b);

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.thousandths.compareTo(a.value.thousandths));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsTitle(periodLabel(provider.period, l10n))),
      ),
      body: entries.isEmpty
          ? Center(child: Text(l10n.noExpensesInPeriod))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AspectRatio(
                  aspectRatio: 1.3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: [
                        for (var i = 0; i < entries.length; i++)
                          PieChartSectionData(
                            value: entries[i].value.toDouble(),
                            color: _chartColors[i % _chartColors.length],
                            title:
                                '${(entries[i].value.thousandths / total.thousandths * 100).toStringAsFixed(0)}%',
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.totalSpent(currency.format(total.toDouble())),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < entries.length; i++)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _chartColors[i % _chartColors.length],
                      child: Text(
                        provider.categoryById(entries[i].key)?.icon ?? '📦',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    title: Text(
                      provider.categoryById(entries[i].key)?.label(l10n) ?? '',
                    ),
                    trailing: Text(
                      currency.format(entries[i].value.toDouble()),
                    ),
                  ),
              ],
            ),
    );
  }
}
