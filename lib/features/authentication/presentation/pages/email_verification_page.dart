import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_orbit/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final String name;

  const EmailVerificationPage({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with WidgetsBindingObserver {
  static const _resendCooldown = 60;

  int _countdown = 0;
  Timer? _timer;
  // Guard flag: set to true once the user successfully verifies, so that
  // backgrounding the app after verification doesn't delete the account.
  bool _hasVerified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Delete the unverified account when the app goes to background or is killed.
    // This frees the email so the user can re-register on next launch.
    // Skip deletion if the user has already verified their email.
    if (!_hasVerified &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached)) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        user.delete();
      }
    }
  }

  void _startCountdown() {
    setState(() => _countdown = _resendCooldown);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
        if (_countdown <= 0) timer.cancel();
      });
    });
  }

  void _onResend() {
    context.read<AuthBloc>().add(AuthSendVerificationEmailRequested());
    _startCountdown();
  }

  void _onCheckVerified() {
    context.read<AuthBloc>().add(
      AuthCheckEmailVerifiedRequested(name: widget.name),
    );
  }

  Future<void> _onBack() async {
    // Delete the unverified Firebase Auth user to free the email for re-registration.
    context.read<AuthBloc>().add(AuthDeleteUnverifiedUserRequested());
    // Small delay to allow the deletion to complete before navigating.
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) context.go('/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthEmailVerified) {
                // Mark as verified so the lifecycle observer no longer deletes the account.
                _hasVerified = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.emailVerificationConfirmButton),
                    backgroundColor: Colors.green,
                  ),
                );
                context.go('/sign-in');
              } else if (state is AuthEmailNotVerified) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message.contains('not yet verified')
                          ? l10n.emailVerificationNotVerifiedError
                          : state.message,
                    ),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: isLoading ? null : _onBack,
                          icon: Icon(
                            Icons.arrow_back,
                            color: theme.colorScheme.onPrimary,
                          ),
                          label: Text(
                            l10n.emailVerificationBackButton,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Email icon
                      Icon(
                        Icons.mark_email_unread_outlined,
                        size: 80,
                        color: theme.colorScheme.onPrimary,
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        l10n.emailVerificationTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Message
                      Text(
                        l10n.emailVerificationMessage(widget.email),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.9,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(),

                      // I've verified button
                      FilledButton(
                        onPressed: isLoading ? null : _onCheckVerified,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.onPrimary,
                          foregroundColor: theme.colorScheme.primary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : Text(
                                l10n.emailVerificationConfirmButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),

                      // Resend button
                      OutlinedButton(
                        onPressed: (_countdown > 0 || isLoading)
                            ? null
                            : _onResend,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onPrimary,
                          side: BorderSide(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _countdown > 0
                              ? l10n.emailVerificationResendCountdown(
                                  _countdown,
                                )
                              : l10n.emailVerificationResendButton,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _countdown > 0
                                ? theme.colorScheme.onPrimary.withValues(
                                    alpha: 0.4,
                                  )
                                : theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
