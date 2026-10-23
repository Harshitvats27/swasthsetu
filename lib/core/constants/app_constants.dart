/// App-wide constant strings, keys, and values.
abstract final class AppConstants {
  // ── App info ────────────────────────────────────────────────────────────────
  static const String appName = 'Swasth Setu';
  static const String appVersion = '1.0.0';

  // ── Organisation ────────────────────────────────────────────────────────────
  static const String hospitalName = 'Aadhar Health Institute';
  static const String tagline = 'Better Health. Better Tomorrow.';
  static const String emergencyPhone = '+91 93045 93045';
  static const String helplnePhone = '+91 97299 13333';
  static const String email = 'aadhar@aadharhealth.com';
  static const String website = 'https://www.aadharhealth.com';

  // ── SharedPreferences keys ─────────────────────────────────────────────────
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyPhoneNumber = 'phone_number';
  static const String keyAuthToken = 'auth_token';
  static const String keyPinSet = 'pin_set';

  // ── Secure-storage keys ────────────────────────────────────────────────────
  static const String secureKeyPin = 'secure_pin';
  static const String secureKeyRefreshToken = 'refresh_token';

  // ── Firestore collection names ─────────────────────────────────────────────
  static const String colUsers = 'users';
  static const String colAppointments = 'appointments';
  static const String colDoctors = 'doctors';
  static const String colPharmacy = 'pharmacy';
  static const String colChat = 'chats';
  static const String colQueue = 'hospital_queue';

  // ── Phone country code ──────────────────────────────────────────────────────
  static const String defaultCountryCode = '+91';

  // ── OTP ─────────────────────────────────────────────────────────────────────
  static const int otpLength = 6;
  static const int pinLength = 4;
  static const int otpTimeoutSeconds = 120;

  // ── Pagination ──────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Health Check API ────────────────────────────────────────────────────────
  static const String healthApiBaseUrl = 'https://swasth-setu-api-vi2x.onrender.com';
}
