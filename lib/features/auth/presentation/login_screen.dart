import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/dialog_service.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_credentials.dart';
import '../models/auth_user.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  AuthUser? _selectedDemoUser;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = ref.read(authProvider);
      setState(() {
        _rememberMe = auth.rememberMe;
        if (auth.savedUsername != null) {
          final mapped = AuthCredentials.userFor(auth.savedUsername!);
          _usernameController.text = mapped?.username ?? auth.savedUsername!;
          _selectedDemoUser = mapped;
          if (mapped != null) {
            _passwordController.text = AuthCredentials.demoPassword;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoAccount(AuthUser? user) {
    setState(() {
      _selectedDemoUser = user;
      if (user == null) {
        _usernameController.clear();
        _passwordController.clear();
        return;
      }
      _usernameController.text = user.username;
      _passwordController.text = AuthCredentials.demoPassword;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final error = await ref.read(authProvider.notifier).login(
            username: _usernameController.text,
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );
      if (!mounted) return;
      if (error != null) {
        await DialogService.showError(
          title: 'Login failed',
          message: error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _forgotPassword() async {
    await DialogService.showAlert(
      title: 'Forgot password',
      message:
          'Password reset will be available after PMIS API integration. '
          'Please contact your IT administrator for assistance.',
      icon: Icons.lock_reset_rounded,
      iconColor: AppColors.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.assignment_rounded,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<AuthUser>(
                      key: ValueKey(
                        _selectedDemoUser?.username ?? 'demo-empty',
                      ),
                      initialValue: _selectedDemoUser,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Demo account',
                        helperText: 'Password auto-fills as 1234',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      hint: const Text('Select a role'),
                      borderRadius: BorderRadius.circular(12),
                      itemHeight: 64,
                      items: [
                        for (final user in AuthCredentials.allUsers)
                          DropdownMenuItem<AuthUser>(
                            value: user,
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _roleIcon(user),
                                    size: 18,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        user.role.shortLabel,
                                        style: theme.textTheme.titleSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Username: ${user.username}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                      selectedItemBuilder: (context) {
                        return [
                          for (final user in AuthCredentials.allUsers)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${user.role.shortLabel}  ·  ${user.username}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ];
                      },
                      onChanged: _isSubmitting ? null : _fillDemoAccount,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'in · pmc · itc',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      onChanged: (value) {
                        final matched = AuthCredentials.userFor(value);
                        if (matched != _selectedDemoUser) {
                          setState(() => _selectedDemoUser = matched);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip:
                              _obscurePassword ? 'Show password' : 'Hide password',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: _isSubmitting
                              ? null
                              : (value) =>
                                  setState(() => _rememberMe = value ?? false),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isSubmitting
                                ? null
                                : () => setState(
                                      () => _rememberMe = !_rememberMe,
                                    ),
                            child: Text(
                              'Remember me',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _isSubmitting ? null : _forgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _roleIcon(AuthUser user) {
    switch (user.role) {
      case UserRole.inspector:
        return Icons.engineering_outlined;
      case UserRole.pmc:
        return Icons.fact_check_outlined;
      case UserRole.itcEngineer:
        return Icons.verified_outlined;
    }
  }
}
