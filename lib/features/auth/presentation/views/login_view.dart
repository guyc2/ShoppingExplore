import 'package:flutter/material.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  final AuthController authController;
  final bool initialIsRegistering;

  const LoginView({
    super.key,
    required this.authController,
    this.initialIsRegistering = false,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  late bool _isRegistering;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isRegistering = widget.initialIsRegistering;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _errorMessage = null);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = l10n?.emailRequired ?? 'Email and password are required');
      return;
    }

    bool success;
    if (_isRegistering) {
      final displayName = _nameController.text.trim();
      if (displayName.isEmpty) {
        setState(() => _errorMessage = l10n?.displayNameRequired ?? 'Display name is required for registration');
        return;
      }
      success = await widget.authController.register(
        email,
        password,
        displayName,
        rememberMe: _rememberMe,
      );
    } else {
      success = await widget.authController.login(
        email,
        password,
        rememberMe: _rememberMe,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      final state = widget.authController.state;
      if (state is AuthError) {
        setState(() => _errorMessage = state.message);
      } else {
        setState(() => _errorMessage = l10n?.authFailed ?? 'Authentication failed');
      }
    }
  }

  Future<void> _debugLoginGuyC() async {
    final success = await widget.authController.login(
      'guy@shoppingexplore.com',
      'password123',
      rememberMe: _rememberMe,
    );
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isRegistering
                    ? (l10n?.createAccount ?? 'Create Account')
                    : (l10n?.signIn ?? 'Sign In'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ActionChip(
                avatar: const Icon(Icons.bug_report_rounded, size: 18),
                label: Text(l10n?.quickDebugGuyC ?? 'Quick Debug Login as Guy C'),
                backgroundColor: colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
                onPressed: _debugLoginGuyC,
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text(l10n?.signIn ?? 'Sign In'),
                    icon: const Icon(Icons.login, size: 18),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text(l10n?.signUp ?? 'Sign Up'),
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                  ),
                ],
                selected: {_isRegistering},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isRegistering = newSelection.first;
                    _errorMessage = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_isRegistering) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n?.displayName ?? 'Display Name',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n?.emailAddress ?? 'Email Address',
                  hintText: 'e.g. user@example.com',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: l10n?.password ?? 'Password',
                  hintText: '••••••••',
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _rememberMe,
                onChanged: (val) {
                  setState(() => _rememberMe = val ?? false);
                },
                title: Text(
                  l10n?.rememberMeOnDevice ?? 'Remember me on this device',
                  style: theme.textTheme.bodyMedium,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n?.cancel ?? 'Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(
                      _isRegistering
                          ? (l10n?.register ?? 'Register')
                          : (l10n?.signIn ?? 'Login'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
