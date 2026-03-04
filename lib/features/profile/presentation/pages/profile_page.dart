import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:task_orbit/core/common/layout/app_shell_layout.dart';
import 'package:task_orbit/core/common/locale/locale_notifier.dart';
import 'package:task_orbit/core/network/connectivity_service.dart';
import 'package:task_orbit/core/auth/app_auth_notifier.dart';
import 'package:task_orbit/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:task_orbit/init_dependencies.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _actionsInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_actionsInitialized) {
      _actionsInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ShellActionsScope.of(context).setActions([]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = serviceLocator<ConnectivityService>();
    final authNotifier = serviceLocator<AppAuthNotifier>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return StreamBuilder<bool>(
      stream: connectivityService.onConnectivityChanged,
      initialData: true,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        if (!isOnline) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.profileNoInternetTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.profileNoInternetMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                _LanguageSwitcherCard(),
              ],
            ),
          );
        }

        return ListenableBuilder(
          listenable: authNotifier,
          builder: (context, _) {
            if (authNotifier.isGuest) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.profileGuestTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.profileGuestMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: () => context.go('/sign-in'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(l10n.profileSignInButton),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => context.go('/sign-up'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(l10n.profileCreateAccountButton),
                      ),
                      const SizedBox(height: 32),
                      _LanguageSwitcherCard(),
                    ],
                  ),
                ),
              );
            }

            return BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state.changePasswordStatus ==
                    ChangePasswordStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.profileChangePasswordSuccess,
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state.changePasswordStatus ==
                    ChangePasswordStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.changePasswordError ??
                            AppLocalizations.of(
                              context,
                            )!.profileChangePasswordError,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _UserInfoCard(
                      name: state.userName,
                      email: state.userEmail,
                    ),
                    const SizedBox(height: 16),
                    _SettingsCard(
                      isLoading:
                          state.changePasswordStatus ==
                          ChangePasswordStatus.loading,
                    ),
                    const SizedBox(height: 16),
                    _StatsCard(state: state),
                    const SizedBox(height: 24),
                    _SignOutButton(),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LanguageSwitcherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = serviceLocator<LocaleNotifier>().value;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.language),
        title: Text(l10n.profileLanguageLabel),
        trailing: DropdownButton<String>(
          value: currentLocale.languageCode,
          underline: const SizedBox.shrink(),
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Text(l10n.profileLanguageEnglish),
            ),
            DropdownMenuItem(
              value: 'vi',
              child: Text(l10n.profileLanguageVietnamese),
            ),
          ],
          onChanged: (code) {
            if (code != null) {
              serviceLocator<LocaleNotifier>().setLocale(Locale(code));
            }
          },
        ),
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  final String name;
  final String email;

  const _UserInfoCard({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 40,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : l10n.profileNamePlaceholder,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isLoading;

  const _SettingsCard({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = serviceLocator<LocaleNotifier>().value;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.profileSettingsTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.profileChangePassword),
            trailing: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: isLoading ? null : () => _showChangePasswordSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.profileLanguageLabel),
            trailing: DropdownButton<String>(
              value: currentLocale.languageCode,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(l10n.profileLanguageEnglish),
                ),
                DropdownMenuItem(
                  value: 'vi',
                  child: Text(l10n.profileLanguageVietnamese),
                ),
              ],
              onChanged: (code) {
                if (code != null) {
                  serviceLocator<LocaleNotifier>().setLocale(Locale(code));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: const _ChangePasswordSheet(),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
      ProfileChangePasswordRequested(
        oldPassword: _oldPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profileChangePassword,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _oldPasswordController,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                labelText: l10n.profileOldPasswordLabel,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty)
                  ? l10n.profilePasswordRequired
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: l10n.profileNewPasswordLabel,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.profilePasswordRequired;
                if (v.length < 6) return l10n.profilePasswordMinLength;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: l10n.profileConfirmPasswordLabel,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.profilePasswordRequired;
                if (v != _newPasswordController.text) {
                  return l10n.profilePasswordMismatch;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.profileChangePasswordButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatefulWidget {
  final ProfileState state;

  const _StatsCard({required this.state});

  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard> {
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
                onToggle: () =>
                    setState(() => _pendingExpanded = !_pendingExpanded),
              ),
              const SizedBox(height: 8),
              _ExpandableStatRow(
                icon: Icons.cancel_outlined,
                color: Theme.of(context).colorScheme.error,
                label: l10n.profileStatsMissed,
                count: state.missedCount,
                expanded: _missedExpanded,
                dates: state.missedDates,
                onToggle: () =>
                    setState(() => _missedExpanded = !_missedExpanded),
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
            month: type == PeriodType.month
                ? (state.selectedMonth ?? DateTime.now().month)
                : null,
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
            items: years
                .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                .toList(),
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
    // Navigate to Agenda with the target date.
    context.go('/agenda', extra: date);
  }
}

class _SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      icon: const Icon(Icons.logout),
      label: Text(l10n.profileSignOut),
      onPressed: () => _showSignOutDialog(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.error,
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileSignOutTitle),
        content: Text(l10n.profileSignOutContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancelButton),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ProfileBloc>().add(ProfileSignOutRequested());
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );
  }
}
