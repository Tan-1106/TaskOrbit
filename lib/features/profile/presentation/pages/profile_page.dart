import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_orbit/core/common/layout/app_shell_layout.dart';
import 'package:task_orbit/core/network/connectivity_service.dart';
import 'package:task_orbit/core/auth/app_auth_notifier.dart';
import 'package:task_orbit/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:task_orbit/features/profile/presentation/widgets/language_switcher_card.dart';
import 'package:task_orbit/features/profile/presentation/widgets/settings_card.dart';
import 'package:task_orbit/features/profile/presentation/widgets/sign_out_button.dart';
import 'package:task_orbit/features/profile/presentation/widgets/stats_card.dart';
import 'package:task_orbit/features/profile/presentation/widgets/user_info_card.dart';
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
        if (mounted) ShellActionsScope.of(context).clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authNotifier = serviceLocator<AppAuthNotifier>();
    final connectivityService = serviceLocator<ConnectivityService>();

    return StreamBuilder<bool>(
      stream: connectivityService.onConnectivityChanged,
      initialData: true,
      builder: (context, snapshot) {

        return ListenableBuilder(
          listenable: authNotifier,
          builder: (context, _) {

            return BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state.changePasswordStatus == ChangePasswordStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.profileChangePasswordSuccess,
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state.changePasswordStatus == ChangePasswordStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.changePasswordError ?? AppLocalizations.of(context)!.profileChangePasswordError,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isOnline = snapshot.data ?? true;
                final isGuest = authNotifier.isGuest;

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
                        StatsCard(state: state),
                        const LanguageSwitcherCard(),
                      ],
                    ),
                  );
                }

                if (isGuest) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SingleChildScrollView(
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
                              onPressed: () => context.push('/sign-in'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: Text(l10n.profileSignInButton),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => context.push('/sign-up'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: Text(l10n.profileCreateAccountButton),
                            ),
                            const SizedBox(height: 32),
                            StatsCard(state: state),
                            const LanguageSwitcherCard(),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    UserInfoCard(
                      name: state.userName,
                      email: state.userEmail,
                    ),
                    const SizedBox(height: 16),
                    SettingsCard(
                      isLoading: state.changePasswordStatus == ChangePasswordStatus.loading,
                    ),
                    const SizedBox(height: 16),
                    StatsCard(state: state),
                    const SizedBox(height: 24),
                    const SignOutButton(),
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
