/// Route name constants for go_router.
/// All named routes are listed here as String constants so they can be
/// referenced type-safely throughout the app without "magic strings".
abstract final class AppRoutes {
  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String pin = '/pin';

  // ── Shell (bottom-nav wrapper) ─────────────────────────────────────────────
  static const String shell = '/shell';

  // ── Home ───────────────────────────────────────────────────────────────────
  static const String home = '/home';

  // ── Profile ────────────────────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String patientDetails = '/patient-details';

  // ── Appointments ───────────────────────────────────────────────────────────
  static const String appointments = '/appointments';
  static const String bookAppointment = '/appointments/book';

  // ── Doctors ────────────────────────────────────────────────────────────────
  static const String doctors = '/doctors';
  static const String doctorDetail = '/doctors/:id';

  // ── Hospitals ───────────────────────────────────────────────────────────────
  static const String hospitals = '/hospitals';
  static const String hospitalDetail = '/hospitals/:id';

  // ── Hospitals queue ────────────────────────────────────────────────────────
  static const String hospitalsQueue = '/hospitals-queue';

  // ── Pharmacy ───────────────────────────────────────────────────────────────
  static const String pharmacy = '/pharmacy';

  // ── SOS ────────────────────────────────────────────────────────────────────
  static const String sos = '/sos';

  // ── Chat ───────────────────────────────────────────────────────────────────
  static const String chat = '/chat';

  // ── AI Search ──────────────────────────────────────────────────────────────
  static const String aiSearch = '/ai-search';
}
