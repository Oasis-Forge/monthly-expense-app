import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/period.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';

/// How strongly a day of another period is dimmed in the strip (DAY-3).
const outsidePeriodOpacity = 0.4;

/// One week of days under the period selector on Home: today keeps a mark of
/// its own, the chosen day is filled, and a day with entries carries a dot
/// (DAY-2, DAY-4). Swiping moves a week at a time, and a day outside the
/// shown period moves the period with it (DAY-3). Tapping the chosen day
/// again goes back to the whole period (DAY-5).
class DayStrip extends StatefulWidget {
  const DayStrip({super.key});

  @override
  State<DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<DayStrip> {
  /// The page the strip opens on, so weeks run both ways from there.
  static const _anchorPage = 1000;

  final _controller = PageController(initialPage: _anchorPage);

  /// The week [_anchorPage] shows; every other page counts from it.
  DateTime? _anchorWeek;

  /// The week the strip last followed the provider to, so a week the user
  /// swiped to isn't pulled back out from under them.
  DateTime? _followedWeek;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime _weekOfPage(int page) {
    final anchor = _anchorWeek!;
    return DateTime(
      anchor.year,
      anchor.month,
      anchor.day + (page - _anchorPage) * 7,
    );
  }

  int _pageOfWeek(DateTime week) =>
      _anchorPage + daysBetween(_anchorWeek!, week) ~/ 7;

  /// Slides to [week] after this frame, unless it is already there.
  void _follow(DateTime week) {
    final page = _pageOfWeek(week);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final from = (_controller.page ?? _anchorPage.toDouble()).round();
      if (from == page) return;
      // A month's jump would otherwise scroll through every week between.
      if ((from - page).abs() > 2) {
        _controller.jumpToPage(page);
        return;
      }
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    // PER-4: the chosen first day of the week, else the locale's (0 is
    // Sunday).
    final firstWeekday =
        settings.weekStartDay ??
        MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final period = provider.period;
    final today = provider.today;
    final selected = provider.selectedDay;
    // Where the strip sits when it hasn't been swiped: the chosen day's week,
    // else today's if this period holds it, else the period's first week
    // that lies mostly inside it (DAY-6). A month starting on a Saturday
    // would otherwise open on six days of the month before.
    final DateTime followWeek;
    if (selected != null || period.contains(today)) {
      followWeek = startOfWeek(selected ?? today, firstWeekday);
    } else {
      final first = startOfWeek(period.start, firstWeekday);
      followWeek = daysBetween(first, period.start) > 3
          ? DateTime(first.year, first.month, first.day + 7)
          : first;
    }
    // A changed first day of the week leaves the old anchor off the grid.
    if (_anchorWeek != null && daysBetween(_anchorWeek!, followWeek) % 7 != 0) {
      _anchorWeek = null;
      _followedWeek = null;
    }
    _anchorWeek ??= followWeek;
    if (_followedWeek != followWeek) {
      _followedWeek = followWeek;
      _follow(followWeek);
    }

    // Bigger text needs a taller strip rather than a clipped one (LANG-4).
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4);
    return SizedBox(
      height: 72 * scale,
      child: PageView.builder(
        controller: _controller,
        itemBuilder: (context, page) {
          final week = _weekOfPage(page);
          final last = DateTime(week.year, week.month, week.day + 6);
          final entryDays = provider.entryDaysIn(week, last);
          return Row(
            children: [
              for (var i = 0; i < 7; i++)
                Builder(
                  builder: (context) {
                    final day = DateTime(week.year, week.month, week.day + i);
                    return Expanded(
                      // A day of another period is dimmed, so choosing it
                      // and landing in that period is no surprise (DAY-3).
                      child: Opacity(
                        opacity: period.contains(day)
                            ? 1
                            : outsidePeriodOpacity,
                        child: _DayChip(
                          day: day,
                          isSelected: day == selected,
                          isToday: day == today,
                          hasEntries: entryDays.contains(day),
                          onTap: () => day == selected
                              ? provider.clearSelectedDay()
                              : provider.selectDay(day),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

/// One day in the strip: its weekday, its number, and a dot when it carries
/// an entry (DAY-2, DAY-4).
class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasEntries,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool hasEntries;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = isSelected
        ? colors.onPrimary
        : isToday
        ? colors.primary
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Material(
        color: isSelected ? colors.primary : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Today stays findable when another day is chosen (DAY-2).
          side: isToday && !isSelected
              ? BorderSide(color: colors.primary)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: Tooltip(
          // DAY-5: the way back to the whole period, which a filled day
          // otherwise doesn't say. A plain date only repeats what the day
          // already reads out, so that one is left out of the semantics.
          excludeFromSemantics: !isSelected,
          message: isSelected
              ? l10n.wholePeriodTooltip
              : DateFormat.yMMMEd(locale).format(day),
          child: InkWell(
            onTap: onTap,
            child: Semantics(
              container: true,
              button: true,
              selected: isSelected,
              label: DateFormat.yMMMEd(locale).format(day),
              excludeSemantics: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat.E(locale).format(day),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat.d(locale).format(day),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // The dot keeps its space either way, so the numbers in a
                  // week stay on one line.
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !hasEntries
                          ? Colors.transparent
                          : isSelected
                          ? colors.onPrimary
                          : colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
