import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source: biometric authentication (local_auth) +
/// secure session storage (flutter_secure_storage / SharedPreferences).
class AuthLocalDataSource {
  AuthLocalDataSource({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
    required LocalAuthentication localAuth,
  })  : _secureStorage = secureStorage,
        _prefs = prefs,
        _localAuth = localAuth;

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;
  final LocalAuthentication _localAuth;

  // ── Keys ─────────────────────────────────────────────────────────────────
  static const _keyUid = 'session_uid';
  static const _keyBiometricEnabled = 'biometric_enabled';

  // ── Session ───────────────────────────────────────────────────────────────

  /// Persists the authenticated user's UID to secure storage.
  Future<void> saveSession({required String uid}) async {
    await _secureStorage.write(key: _keyUid, value: uid);
  }

  /// Returns the saved UID, or null if no session exists.
  Future<String?> getSession() => _secureStorage.read(key: _keyUid);

  /// Deletes the stored session.
  Future<void> clearSession() => _secureStorage.delete(key: _keyUid);

  // ── Biometric preference ──────────────────────────────────────────────────

  /// Persists whether the user has opted in to biometric unlock.
  Future<void> setBiometricEnabled({required bool enabled}) =>
      _prefs.setBool(_keyBiometricEnabled, enabled).then((_) {});

  /// Returns the user's biometric preference (false by default).
  bool get isBiometricEnabled => _prefs.getBool(_keyBiometricEnabled) ?? false;

  // ── Biometric auth ────────────────────────────────────────────────────────

  /// Returns true if the device supports biometric authentication and has
  /// enrolled credentials.
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isDeviceSupported) return false;

      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the user with the OS biometric dialog.
  ///
  /// Returns true if the user authenticates successfully.
  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Use your fingerprint or face to log in to SwasthSetu',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow device PIN fallback
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
