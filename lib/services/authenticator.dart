import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

enum AuthResult {
  success,

  /// The user cancelled or wasn't recognized.
  failed,

  /// The device has no biometrics or screen lock to check (LOCK-3).
  unavailable,
}

/// Checks the device owner with the device's biometrics or screen lock, so
/// the app never stores a PIN of its own (LOCK-1).
abstract class Authenticator {
  /// Whether this device has biometrics or a screen lock the app can use.
  Future<bool> isAvailable();

  /// Asks the user to authenticate, showing [reason] as the prompt's title,
  /// [hint] as its subtitle, and [cancelButton] on the button that backs
  /// out — all from the caller's own translations (LANG-2), so the dialog
  /// isn't left in local_auth's untranslated English defaults.
  Future<AuthResult> authenticate(
    String reason, {
    String? hint,
    String? cancelButton,
  });
}

/// [Authenticator] backed by `local_auth` on Android, iOS, macOS, and
/// Windows. Other platforms have no app lock.
class DeviceAuthenticator implements Authenticator {
  final _auth = LocalAuthentication();

  static bool get _supportedPlatform =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.macOS ||
        TargetPlatform.windows => true,
        _ => false,
      };

  @override
  Future<bool> isAvailable() async {
    if (!_supportedPlatform) return false;
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthResult> authenticate(
    String reason, {
    String? hint,
    String? cancelButton,
  }) async {
    if (!await isAvailable()) return AuthResult.unavailable;
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: reason,
            signInHint: hint,
            cancelButton: cancelButton,
          ),
          IOSAuthMessages(cancelButton: cancelButton),
          const WindowsAuthMessages(),
        ],
      );
      return ok ? AuthResult.success : AuthResult.failed;
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.noBiometricHardware => AuthResult.unavailable,
        _ => AuthResult.failed,
      };
    }
  }
}
