import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:task_orbit/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

class StatsCard extends StatefulWidget {
  final ProfileState state;

  const StatsCard({super.key, required this.state});

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  bool _pendingExpanded = false;
  bool _missedExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = widget.state;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.profileStatsTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reload',
                  onPressed: state.statsLoading
                      ? null
                      : () {
                    context.read<ProfileBloc>().add(
                      ProfileReloadRequested(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PeriodToggle(state: state),
            const SizedBox(height: 12),
            _PeriodPicker(state: state),
            const Divider(height: 24),
            if (state.statsLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _StatRow(
                icon: Icons.check_circle_outline,
                color: Colors.green,
                label: l10n.profileStatsCompleted,
                count: state.completedCount,
              ),
              const SizedBox(height: 8),
              _ExpandableStatRow(
                icon: Icons.hourglass_top,
                color: Colors.orange,
                label: l10n.profileStatsIncomplete,
                count: state.pendingCount,
                expanded: _pendingExpanded,
                dates: state.pendingDates,
                onToggle: () => setState(() => _pendingExpanded = !_pendingExpanded),
              ),
              const SizedBox(height: 8),
              _ExpandableStatRow(
                icon: Icons.cancel_outlined,
                color: Theme.of(context).colorScheme.error,
                label: l10n.profileStatsMissed,
                count: state.missedCount,
                expanded: _missedExpanded,
                dates: state.missedDates,
                onToggle: () => setState(() => _missedExpanded = !_missedExpanded),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final ProfileState state;

  const _PeriodToggle({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ProfileBloc>();

    return SegmentedButton<PeriodType>(
      segments: [
        ButtonSegment(
          value: PeriodType.month,
          label: Text(l10n.profilePeriodMonth),
          icon: const Icon(Icons.calendar_view_month),
        ),
        ButtonSegment(
          value: PeriodType.year,
          label: Text(l10n.profilePeriodYear),
          icon: const Icon(Icons.calendar_today),
        ),
      ],
      selected: {state.periodType},
      onSelectionChanged: (selection) {
        final type = selection.first;
        bloc.add(
          ProfilePeriodChanged(
            periodType: type,
            year: state.selectedYear ?? DateTime.now().year,
            month: type == PeriodType.month ? (state.selectedMonth ?? DateTime.now().month) : null,
          ),
        );
      },
    );
  }
}

class _PeriodPicker extends StatelessWidget {
  final ProfileState state;

  const _PeriodPicker({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ProfileBloc>();
    final now = DateTime.now();

    final locale = Localizations.localeOf(context).toString();
    final years = List.generate(11, (i) => now.year - 5 + i);
    final months = List.generate(12, (i) => i + 1);

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: state.selectedYear ?? now.year,
            decoration: InputDecoration(
              labelText: l10n.profilePeriodYear,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
            onChanged: (y) {
              if (y == null) return;
              bloc.add(
                ProfilePeriodChanged(
                  periodType: state.periodType,
                  year: y,
                  month: state.selectedMonth,
                ),
              );
            },
          ),
        ),
        if (state.periodType == PeriodType.month) ...[
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: state.selectedMonth ?? now.month,
              decoration: InputDecoration(
                labelText: l10n.profilePeriodMonth,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: months
                  .map(
                    (m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                    DateFormat.MMMM(locale).format(DateTime(2000, m)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
                  .toList(),
              onChanged: (m) {
                if (m == null) return;
                bloc.add(
                  ProfilePeriodChanged(
                    periodType: state.periodType,
                    year: state.selectedYear ?? now.year,
                    month: m,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;

  const _StatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandableStatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  final bool expanded;
  final Map<DateTime, int> dates;
  final VoidCallback onToggle;

  const _ExpandableStatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
    required this.expanded,
    required this.dates,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedDates = dates.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: count > 0 ? onToggle : null,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: theme.textTheme.bodyMedium),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
        if (expanded && sortedDates.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 34, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sortedDates.map((date) {
                final taskCount = dates[date]!;
                return _DateChip(
                  date: date,
                  taskCount: taskCount,
                  color: color,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final int taskCount;
  final Color color;

  const _DateChip({
    required this.date,
    required this.taskCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = DateFormat('EEE, d MMM yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ActionChip(
        avatar: Icon(Icons.calendar_today, size: 14, color: color),
        label: Text(
          '$formatted  ($taskCount)',
          style: theme.textTheme.labelMedium,
        ),
        onPressed: () => _navigateToDate(context, date),
        backgroundColor: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  void _navigateToDate(BuildContext context, DateTime date) {
    context.go('/agenda', extra: date);
  }
}