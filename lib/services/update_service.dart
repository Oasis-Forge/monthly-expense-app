import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:in_app_update/in_app_update.dart';

/// Play's own flexible update flow (UPD-1). Behind an interface so that no
/// test reaches the plugin, which needs a Play-installed build to answer.
abstract class UpdateService {
  /// Whether this build can offer an update at all (UPD-5).
  bool get supported;

  /// Whether Play is holding a newer version that can be taken in the
  /// background. False for anything Play will not let us take flexibly,
  /// including an update it wants installed immediately: blocking the app
  /// is not ours to do.
  Future<bool> available();

  /// Asks Play to show its sheet and download in the background. Answers
  /// true once the download has finished, false if it was declined, failed
  /// or was cancelled -- all of which are the same to the app.
  Future<bool> download();

  /// Whether Play is already holding a finished download from an earlier
  /// run of the app, so the restart can be offered again without starting
  /// another download (UPD-1): the ask is at most once a day, but a
  /// download that finished in the background and lost its restart offer
  /// (the app was closed, or a later message pushed it off screen) would
  /// otherwise sit there with no way back in.
  Future<bool> downloaded();

  /// Installs what was downloaded, which restarts the app.
  Future<void> install();
}

class DeviceUpdates implements UpdateService {
  const DeviceUpdates();

  @override
  bool get supported => defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<bool> available() async {
    if (!supported) return false;
    try {
      final info = await InAppUpdate.checkForUpdate();
      return info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.flexibleUpdateAllowed;
    } catch (_) {
      // A build that did not come from Play, no network, or Play itself
      // being unwell. None of it is the app's business (UPD-1).
      return false;
    }
  }

  @override
  Future<bool> download() async {
    try {
      return await InAppUpdate.startFlexibleUpdate() == AppUpdateResult.success;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> downloaded() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      return info.installStatus == InstallStatus.downloaded;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> install() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (_) {
      // The restart is Play's to do; if it will not, the next launch picks
      // the update up in the ordinary way.
    }
  }
}

/// iOS, and the desktop builds, which carry no update code that could reach
/// a network (UPD-5, RUN-2).
class NoUpdates implements UpdateService {
  const NoUpdates();

  @override
  bool get supported => false;

  @override
  Future<bool> available() async => false;

  @override
  Future<bool> download() async => false;

  @override
  Future<bool> downloaded() async => false;

  @override
  Future<void> install() async {}
}

/// Play's flow on Android, nothing anywhere else (UPD-5).
UpdateService deviceOrNoUpdates() =>
    defaultTargetPlatform == TargetPlatform.android
    ? const DeviceUpdates()
    : const NoUpdates();
