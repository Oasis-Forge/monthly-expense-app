import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/csv_export.dart' show isoDate;
import '../models/report.dart';
import '../models/transaction_filter.dart';
import '../providers/ads_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/report_fonts.dart';
import '../services/report_pdf.dart';
import 'form_fields.dart';

/// Chooses what a PDF report covers and what it leaves out, then builds and
/// previews it (PDF-1, PDF-3, PDF-4).
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, this.filter});

  /// Set from Search, so the report covers what's on screen there (PDF-1,
  /// BAK-5). Its dates seed the custom range.
  final TransactionFilter? filter;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportRange _range = ReportRange.period;
  late DateTime _from;
  late DateTime _to;
  late int _year;
  String? _accountId;
  var _options = const ReportOptions();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TransactionProvider>();
    final period = provider.period;
    final filter = widget.filter;
    _from = filter?.from ?? period.start;
    _to = filter?.to ?? period.lastDay;
    _year = period.start.year;
    if (filter != null && (filter.from != null || filter.to != null)) {
      _range = ReportRange.custom;
    }
  }

  /// The days the chosen range covers, both included.
  (DateTime, DateTime) get _dates => switch (_range) {
    ReportRange.period => (
      context.read<TransactionProvider>().period.start,
      context.read<TransactionProvider>().period.lastDay,
    ),
    ReportRange.custom => (_from, _to),
    ReportRange.year => (DateTime(_year), DateTime(_year, 12, 31)),
  };

  Future<void> _create() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    final settings = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ads = context.read<AdsProvider>();
    final locale = Localizations.localeOf(context);
    final (from, to) = _dates;

    if (to.isBefore(from)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reportRangeBackwards)),
      );
      return;
    }

    setState(() => _busy = true);
    // Making a report is a job with an end, so the full-screen ad for the
    // seam at the end of it is fetched while the pages are built, never
    // waited for (ADS-11, ADS-13).
    unawaited(ads.primeInterstitial());
    final progress = ValueNotifier<double>(0);
    var cancelled = false;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _BuildingDialog(
          progress: progress,
          onCancel: () {
            cancelled = true;
            Navigator.of(context).pop();
          },
        ),
      ),
    );

    try {
      final data = buildReport(
        from: from,
        to: to,
        today: provider.today,
        transactions: provider.transactions,
        transfers: provider.transfers,
        accounts: provider.accounts,
        accountId: _accountId,
        budgetLimit: (id) => provider.budgetLimit(id),
        startDay: provider.startDay,
        options: _options,
      );
      final bytes = await buildReportPdf(
        data: data,
        options: _options,
        labels: ReportLabels(
          l10n: l10n,
          locale: locale,
          currency: settings.currencyFormat(l10n.localeName, isolated: false),
          categoryName: (id) => provider.categoryById(id)?.label(l10n) ?? '',
          accountName: (id) => provider.accountById(id)?.label(l10n) ?? '',
          accountFilterName: _accountId == null
              ? null
              : provider.accountById(_accountId!)?.label(l10n),
        ),
        fonts: await ReportFonts.forLocale(locale),
        createdAt: DateTime.now(),
        pageFormat: _paperFor(locale),
        onProgress: (value) => progress.value = value,
        isCancelled: () => cancelled,
      );
      if (!mounted) return;
      navigator.pop(); // the progress dialog
      await navigator.push(
        MaterialPageRoute(
          builder: (_) => _ReportPreview(
            bytes: bytes,
            fileName: 'monthly-expenses-${isoDate(from)}_${isoDate(to)}.pdf',
          ),
        ),
      );
      // The report was made and its preview closed again: a seam (ADS-11),
      // reached with nothing half-finished behind it (ADS-14).
      await ads.showAtSeam(AdSeam.madeReport);
    } on ReportCancelled {
      // The dialog already closed itself; nothing was produced (PDF-6).
    } catch (_) {
      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(SnackBar(content: Text(l10n.reportFailed)));
      }
    } finally {
      progress.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();

    // PDF-7: the app carries no face for this script, so a report would come
    // out as empty boxes. Say so instead of building one.
    if (!ReportFonts.supports(Localizations.localeOf(context))) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportTitle)),
        body: const _NoFont(),
      );
    }

    final years = _yearsWithData(provider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.reportCoversHeader, style: _sectionStyle(context)),
          const SizedBox(height: 8),
          SegmentedButton<ReportRange>(
            segments: [
              ButtonSegment(
                value: ReportRange.period,
                label: Text(l10n.reportRangePeriod),
              ),
              ButtonSegment(
                value: ReportRange.custom,
                label: Text(l10n.reportRangeCustom),
              ),
              ButtonSegment(
                value: ReportRange.year,
                label: Text(l10n.reportRangeYear),
              ),
            ],
            selected: {_range},
            onSelectionChanged: (chosen) =>
                setState(() => _range = chosen.first),
          ),
          if (_range == ReportRange.custom) ...[
            const SizedBox(height: 12),
            DateField(
              label: l10n.reportFromLabel,
              date: _from,
              onChanged: (date) => setState(() => _from = date),
            ),
            const SizedBox(height: 12),
            DateField(
              label: l10n.reportToLabel,
              date: _to,
              onChanged: (date) => setState(() => _to = date),
            ),
          ],
          if (_range == ReportRange.year) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: years.contains(_year) ? _year : years.first,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.reportYearLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final year in years)
                  DropdownMenuItem(value: year, child: Text('$year')),
              ],
              onChanged: (value) => setState(() => _year = value ?? _year),
            ),
          ],
          const SizedBox(height: 20),
          DropdownButtonFormField<String?>(
            initialValue: _accountId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.reportAccountLabel,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(child: Text(l10n.reportAllAccounts)),
              for (final account in provider.activeAccounts)
                DropdownMenuItem(
                  value: account.id,
                  child: Text(account.label(l10n)),
                ),
            ],
            onChanged: (value) => setState(() => _accountId = value),
          ),
          const SizedBox(height: 20),
          Text(l10n.reportIncludeHeader, style: _sectionStyle(context)),
          Text(l10n.reportIncludeSubtitle, style: _mutedStyle(context)),
          _IncludeSwitch(
            label: l10n.reportIncludeTransactions,
            value: _options.transactions,
            onChanged: (on) =>
                setState(() => _options = _options.copyWith(transactions: on)),
          ),
          // Both only say anything while the entry list is in.
          _IncludeSwitch(
            label: l10n.reportIncludeDetails,
            value: _options.titlesAndNotes,
            onChanged: _options.transactions
                ? (on) => setState(
                    () => _options = _options.copyWith(titlesAndNotes: on),
                  )
                : null,
          ),
          _IncludeSwitch(
            label: l10n.reportIncludeAccounts,
            value: _options.accountNames,
            onChanged: _options.transactions
                ? (on) => setState(
                    () => _options = _options.copyWith(accountNames: on),
                  )
                : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _create,
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            child: Text(l10n.reportCreateButton),
          ),
        ],
      ),
    );
  }

  TextStyle? _sectionStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;

  TextStyle? _mutedStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

  /// The years there is anything to report on, newest first, always including
  /// the selected period's.
  List<int> _yearsWithData(TransactionProvider provider) {
    final years = {
      provider.period.start.year,
      for (final tx in provider.transactions) tx.date.year,
      for (final transfer in provider.transfers) transfer.date.year,
    }.toList()..sort((a, b) => b.compareTo(a));
    return years;
  }
}

/// One of the "leave this out" switches (PDF-3); null [onChanged] greys it.
class _IncludeSwitch extends StatelessWidget {
  const _IncludeSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    value: value,
    onChanged: onChanged,
  );
}

/// A4 everywhere except the places that use US Letter (PDF-5).
PdfPageFormat _paperFor(Locale locale) {
  const letterCountries = {'US', 'CA', 'MX', 'PH', 'CL', 'CO', 'CR', 'GT'};
  return letterCountries.contains(locale.countryCode)
      ? PdfPageFormat.letter
      : PdfPageFormat.a4;
}

/// Progress while the report is laid out, with a way out (PDF-6).
class _BuildingDialog extends StatelessWidget {
  const _BuildingDialog({required this.progress, required this.onCancel});

  final ValueNotifier<double> progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.reportBuilding),
      content: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (context, value, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: value == 0 ? null : value),
            const SizedBox(height: 12),
            Text(NumberFormat.percentPattern(l10n.localeName).format(value)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: Text(l10n.cancelButton)),
      ],
    );
  }
}

/// The finished report, which the user can then share, save, or print —
/// never before (PDF-4).
class _ReportPreview extends StatelessWidget {
  const _ReportPreview({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportPreviewTitle)),
      body: PdfPreview(
        build: (_) => bytes,
        pdfFileName: fileName,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
      ),
    );
  }
}

/// Why there is no report in Chinese, Japanese or Korean yet (PDF-7).
class _NoFont extends StatelessWidget {
  const _NoFont();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.font_download_off_outlined,
              size: 56,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.reportNoFontTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.reportNoFontBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
