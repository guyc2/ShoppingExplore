import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  final AuthController authController;

  const LoginView({super.key, required this.authController});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController(text: 'user@shoppingexplore.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _nameController = TextEditingController();
  bool _isRegistering = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Email and password are required');
      return;
    }

    bool success;
    if (_isRegistering) {
      final displayName = _nameController.text.trim();
      if (displayName.isEmpty) {
        setState(() => _errorMessage = 'Display name is required for registration');
        return;
      }
      success = await widget.authController.register(email, password, displayName);
    } else {
      success = await widget.authController.login(email, password);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      final state = widget.authController.state;
      if (state is AuthError) {
        setState(() => _errorMessage = state.message);
      } else {
        setState(() => _errorMessage = 'Authentication failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isRegistering ? 'Create Account' : 'Sign In',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
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
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_isRegistering) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(_isRegistering ? 'Register' : 'Login'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isRegistering = !_isRegistering),
                  child: Text(
                    _isRegistering
                        ? 'Already have an account? Sign In'
                        : 'Need an account? Register',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
