import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
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
    final provider = context.watch<TransactionProvider>();
    final byCategory = provider.expenseByCategory;
    final currency = NumberFormat.currency(symbol: '\$');
    final total = byCategory.values.fold(0.0, (a, b) => a + b);

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stats — ${DateFormat.yMMMM().format(provider.selectedMonth)}',
        ),
      ),
      body: entries.isEmpty
          ? const Center(child: Text('No expenses this month yet.'))
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
                            value: entries[i].value,
                            color: _chartColors[i % _chartColors.length],
                            title:
                                '${(entries[i].value / total * 100).toStringAsFixed(0)}%',
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
                  'Total spent: ${currency.format(total)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < entries.length; i++)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _chartColors[i % _chartColors.length],
                      child: Text(
                        Categories.icons[entries[i].key] ?? '📦',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    title: Text(entries[i].key),
                    trailing: Text(currency.format(entries[i].value)),
                  ),
              ],
            ),
    );
  }
}
