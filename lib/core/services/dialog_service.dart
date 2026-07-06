import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'error_handler.dart';

class DialogService {
  DialogService._();

  static BuildContext? get _context => ErrorHandler.navigatorKey.currentContext;

  static Future<void> showError({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) async {
    final context = _context;
    if (context == null || !context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
        primaryAction: onRetry != null ? 'Retry' : 'OK',
        onPrimary: () {
          Navigator.of(ctx).pop();
          onRetry?.call();
        },
        secondaryAction: onRetry != null ? 'Cancel' : null,
        onSecondary: onRetry != null ? () => Navigator.of(ctx).pop() : null,
      ),
    );
  }

  static Future<void> showSuccess({
    required String title,
    required String message,
    VoidCallback? onDone,
  }) async {
    final context = _context;
    if (context == null || !context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        icon: Icons.check_circle_outline_rounded,
        iconColor: AppColors.success,
        primaryAction: 'Done',
        onPrimary: () {
          Navigator.of(ctx).pop();
          onDone?.call();
        },
      ),
    );
  }

  static Future<bool?> showConfirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) async {
    final context = _context;
    if (context == null || !context.mounted) return false;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        icon: Icons.help_outline_rounded,
        iconColor: AppColors.warning,
        primaryAction: confirmLabel,
        onPrimary: () => Navigator.of(ctx).pop(true),
        secondaryAction: cancelLabel,
        onSecondary: () => Navigator.of(ctx).pop(false),
      ),
    );
  }
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.primaryAction,
    required this.onPrimary,
    this.secondaryAction,
    this.onSecondary,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String primaryAction;
  final VoidCallback onPrimary;
  final String? secondaryAction;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (secondaryAction != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      child: Text(secondaryAction!),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimary,
                    child: Text(primaryAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
