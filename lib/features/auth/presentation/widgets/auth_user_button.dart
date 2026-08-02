import 'package:flutter/material.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../controllers/auth_controller.dart';
import '../views/account_profile_modal.dart';
import '../views/login_view.dart';

class AuthUserButton extends StatelessWidget {
  final AuthController authController;

  const AuthUserButton({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authController,
      builder: (context, _) {
        final state = authController.state;
        final colorScheme = Theme.of(context).colorScheme;
        final l10n = AppLocalizations.of(context);

        if (state is Authenticated) {
          return PopupMenuButton<String>(
            tooltip: 'Account: ${state.user.displayName}',
            onSelected: (value) {
              if (value == 'logout') {
                authController.logout();
              } else if (value == 'profile') {
                showDialog<void>(
                  context: context,
                  builder: (_) => AccountProfileModal(
                    authController: authController,
                  ),
                );
              } else if (value == 'switch') {
                showDialog<void>(
                  context: context,
                  builder: (_) => LoginView(
                    authController: authController,
                    initialIsRegistering: false,
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  l10n != null
                      ? l10n.signedInAs(state.user.email)
                      : 'Signed in as:\n${state.user.email}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n?.accountProfile ?? 'Account & Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'switch',
                child: Row(
                  children: [
                    const Icon(Icons.switch_account, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n?.switchAccount ?? 'Switch Account'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n?.signOut ?? 'Sign Out'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    child: Text(
                      state.user.displayName.isNotEmpty
                          ? state.user.displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.user.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => LoginView(
                    authController: authController,
                    initialIsRegistering: false,
                  ),
                );
              },
              icon: const Icon(Icons.login, size: 18),
              label: Text(l10n?.signIn ?? 'Sign In'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => LoginView(
                    authController: authController,
                    initialIsRegistering: true,
                  ),
                );
              },
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: Text(l10n?.signUp ?? 'Sign Up'),
            ),
            const SizedBox(width: 4),
          ],
        );
      },
    );
  }
}
