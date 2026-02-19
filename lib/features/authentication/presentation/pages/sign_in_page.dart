import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_orbit/l10n/app_localizations.dart';
import 'package:task_orbit/features/authentication/presentation/painters/sign_in_background.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: SignInBackground(context),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 40,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.20,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        spacing: 20,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.signInQuote,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.signInEmailLabel,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.signInEmailRequired;
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return AppLocalizations.of(context)!.signInEmailInvalid;
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.signInPasswordLabel,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.signInPasswordRequired;
                              }
                              if (value.length < 6) {
                                return AppLocalizations.of(context)!.signInPasswordMinLength;
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  /* TODO */
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.signInForgotPassword,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                AppLocalizations.of(context)!.signInRememberMe,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(6, 0),
                                child: Checkbox(
                                  value: rememberMe,
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMe = value ?? false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                /* TODO */
                              },
                              child: Text(
                                AppLocalizations.of(context)!.signInButton,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.signInNoAccount,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push('/sign-up');
                          },
                          child: Text(
                            AppLocalizations.of(context)!.signInSignUp,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
