import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import 'home_screen.dart';
import 'setup_screen.dart';
import 'walkthrough_screen.dart';

/// What the app opens on: setup until it is finished, then the walkthrough
/// once, then Home (RUN-3–RUN-5). An update onto a device that has used the
/// app before goes straight to Home.
class FirstRunGate extends StatelessWidget {
  const FirstRunGate({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    if (!settings.setupDone) return const SetupScreen();
    if (!settings.walkthroughSeen) return const WalkthroughScreen();
    return const HomeScreen();
  }
}
