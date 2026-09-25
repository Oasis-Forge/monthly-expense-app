import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Shown instead of an empty Home when this build refuses to open a database
/// a newer build already upgraded (an installer downgrade, `adb install -d`,
/// or a device moved onto an older release track) (x-downgrade-message).
/// There is nothing to offer but the explanation: the fix is an update from
/// the store, and the app has no way to trigger that itself.
class DatabaseTooNewScreen extends StatelessWidget {
  const DatabaseTooNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.system_update_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.dbTooNewTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dbTooNewMessage,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
