import 'package:flutter/material.dart';

/// Shared soft-keyboard helpers for Android and iOS.
class KeyboardDismiss {
  KeyboardDismiss._();

  /// Hides the soft keyboard and clears text focus.
  static void hide([BuildContext? context]) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (context != null) {
      FocusScope.of(context).unfocus();
    }
  }

  /// Use with [TextField.onTapOutside] / [TextFormField.onTapOutside].
  static void onTapOutside(PointerDownEvent _) => hide();
}

/// App-wide keyboard UX for Android and iOS:
/// - drag/scroll dismisses the keyboard
/// - a "Done" bar sits above the keyboard (covers iOS number-pad missing key)
class KeyboardDismissScope extends StatefulWidget {
  const KeyboardDismissScope({super.key, required this.child});

  final Widget child;

  static const double doneBarHeight = 44;

  @override
  State<KeyboardDismissScope> createState() => _KeyboardDismissScopeState();
}

class _KeyboardDismissScopeState extends State<KeyboardDismissScope> {
  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final hasFocus = FocusManager.instance.primaryFocus?.hasFocus ?? false;
    final showDoneBar = bottomInset > 0 && hasFocus;
    final barHeight = showDoneBar ? KeyboardDismissScope.doneBarHeight : 0.0;
    final theme = Theme.of(context);

    return MediaQuery(
      // Reserve space for the Done bar so it does not cover form fields.
      data: mediaQuery.copyWith(
        viewInsets: mediaQuery.viewInsets.copyWith(
          bottom: bottomInset + barHeight,
        ),
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Dismiss while the user drags any scrollable (forms, lists, login).
          if (notification is ScrollUpdateNotification &&
              notification.dragDetails != null &&
              (FocusManager.instance.primaryFocus?.hasFocus ?? false)) {
            KeyboardDismiss.hide();
          }
          return false;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (showDoneBar)
              Positioned(
                left: 0,
                right: 0,
                // Sit just above the system keyboard (original inset).
                bottom: bottomInset,
                child: Material(
                  elevation: 6,
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: SizedBox(
                    height: KeyboardDismissScope.doneBarHeight,
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          Icons.keyboard_hide_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Close keyboard',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: KeyboardDismiss.hide,
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
