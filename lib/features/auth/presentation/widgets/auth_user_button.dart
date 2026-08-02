import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
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

        if (state is Authenticated) {
          return PopupMenuButton<String>(
            tooltip: 'Account: ${state.user.displayName}',
            onSelected: (value) {
              if (value == 'logout') {
                authController.logout();
              } else if (value == 'switch') {
                showDialog<void>(
                  context: context,
                  builder: (_) => LoginView(authController: authController),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  'Signed in as:\n${state.user.email}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'switch',
                child: Row(
                  children: [
                    Icon(Icons.switch_account, size: 18),
                    SizedBox(width: 8),
                    Text('Switch Account'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Sign Out'),
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

        return TextButton.icon(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (_) => LoginView(authController: authController),
            );
          },
          icon: const Icon(Icons.person_outline, size: 20),
          label: const Text('Sign In'),
        );
      },
    );
  }
}
