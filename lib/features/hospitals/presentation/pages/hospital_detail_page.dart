import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:swasthsetu/core/router/app_routes.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_bloc.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_event.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_state.dart';
import 'package:swasthsetu/features/doctors/data/models/doctor_model.dart';
import 'package:swasthsetu/features/hospitals/data/models/hospital_model.dart';
import 'package:swasthsetu/features/appointments/presentation/widgets/appointment_booking_sheet.dart';
import 'package:swasthsetu/core/di/injection_container.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalDetailPage extends StatefulWidget {
  final HospitalModel hospital;

  const HospitalDetailPage({super.key, required this.hospital});

  @override
  State<HospitalDetailPage> createState() => _HospitalDetailPageState();
}

class _HospitalDetailPageState extends State<HospitalDetailPage> {
  final PageController _doctorPageController = PageController(
    viewportFraction: 0.85,
  );
  int _currentDoctorPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<DoctorBloc>().add(LoadDoctorsEvent());
  }

  @override
  void dispose() {
    _doctorPageController.dispose();
    super.dispose();
  }

  bool get _isMultiSpecialty => widget.hospital.specialties.length > 1;

  List<DoctorModel> _filterDoctors(List<DoctorModel> all) {
    return all
        .where((d) => d.clinicName == widget.hospital.name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hospital = widget.hospital;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(hospital),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickActions(hospital),
                BlocBuilder<DoctorBloc, DoctorState>(
                  builder: (context, state) {
                    if (state is DoctorLoaded) {
                      final docs = _filterDoctors(state.doctors);
                      return _buildLiveQueueSection(docs);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                _buildAboutSection(hospital),
                _buildSpecialtiesSection(hospital),
                _buildFacilitiesSection(hospital),
                _buildDoctorsSection(),
                _buildMapPlaceholder(hospital),
                const SizedBox(height: 100), // FAB clearance
              ],
            ),
          ),
        ],
      ),
      // ── Floating book button ──────────────────────────────────────────────
      bottomNavigationBar: _buildBookingBar(hospital),
    );
  }

  // ── Sliver App Bar ─────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(HospitalModel hospital) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hospital.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 3),
                              Text(
                                '${hospital.rating} (${hospital.reviewsCount} reviews)',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (hospital.isOpen24x7)
                                _badge('24×7 Open', Colors.green),
                              const SizedBox(width: 6),
                              _badge(
                                _isMultiSpecialty
                                    ? 'Multi-Specialty'
                                    : 'Specialty Clinic',
                                Colors.blue.shade700,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions(HospitalModel hospital) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _quickActionBtn(
            icon: Icons.phone,
            label: 'Call',
            color: Colors.green,
            onTap: () async {
              final phoneUrl = Uri.parse('tel:${hospital.phone}');
              if (await canLaunchUrl(phoneUrl)) {
                await launchUrl(phoneUrl);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open phone dialer')),
                );
              }
            },
          ),
          _quickActionBtn(
            icon: Icons.directions,
            label: 'Directions',
            color: AppColors.primary,
            onTap: () async {
              final lat = hospital.geoPoint.latitude;
              final lng = hospital.geoPoint.longitude;
              final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open maps')),
                );
              }
            },
          ),
          _quickActionBtn(
            icon: Icons.share,
            label: 'Share',
            color: Colors.orange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing hospital info...')),
              );
            },
          ),
          _quickActionBtn(
            icon: Icons.bookmark_border,
            label: 'Save',
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hospital saved!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quickActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Live Queue Status ─────────────────────────────────────────────────────
  Widget _buildLiveQueueSection(List<DoctorModel> doctors) {
    if (doctors.isEmpty) return const SizedBox.shrink();
    
    // For a hospital (OPD), the queue is hospital-wide for the day.
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docId = '${widget.hospital.id}_$today';

    return StreamBuilder<DocumentSnapshot>(
      stream: sl<FirebaseFirestore>().collection('daily_queues').doc(docId).snapshots(),
      builder: (context, snapshot) {
        int currentToken = 0;
        int estimatedWait = 0;
        int lastTokenIssued = 0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            currentToken = data['currentTokenServing'] as int? ?? 0;
            lastTokenIssued = data['lastTokenIssued'] as int? ?? 0;
            final avgWait = data['averageConsultationMinutes'] as int? ?? 15;
            
            final patientsAhead = lastTokenIssued - currentToken;
            estimatedWait = patientsAhead > 0 ? patientsAhead * avgWait : 0;
          }
        }

        return _sectionCard(
          title: '🔴 Live Queue Status (OPD)',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _queueStatBox(
                      'Currently Serving',
                      currentToken > 0 ? 'Token $currentToken' : 'Waiting...',
                      Icons.people_alt_outlined,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _queueStatBox(
                      'Est. Wait Time',
                      '$estimatedWait mins',
                      Icons.timer_outlined,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Book now to get Token ${lastTokenIssued + 1}.',
                        style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _queueStatBox(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // ── About ─────────────────────────────────────────────────────────────────
  Widget _buildAboutSection(HospitalModel hospital) {
    return _sectionCard(
      title: 'About',
      child: Column(
        children: [
          _infoRow(Icons.place_outlined, 'Address', hospital.address),
          const Divider(height: 20),
          _infoRow(Icons.phone_outlined, 'Phone', hospital.phone),
          const Divider(height: 20),
          _infoRow(Icons.bed, 'Total Beds', '${hospital.totalBeds} beds'),
          const Divider(height: 20),
          _infoRow(
            Icons.access_time,
            'Timings',
            hospital.isOpen24x7
                ? 'Open 24 × 7'
                : 'Mon–Sat: 9:00 AM – 8:00 PM',
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.location_city,
            'City',
            '${hospital.city}, ${hospital.state}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Specialties ───────────────────────────────────────────────────────────
  Widget _buildSpecialtiesSection(HospitalModel hospital) {
    return _sectionCard(
      title: 'Specialties',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: hospital.specialties.map((s) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              s,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Facilities ────────────────────────────────────────────────────────────
  static const Map<String, IconData> _facilityIcons = {
    'ICU': Icons.monitor_heart,
    'OT': Icons.medical_services,
    'Pharmacy': Icons.local_pharmacy,
    'Ambulance': Icons.emergency,
    'Blood Bank': Icons.bloodtype,
    'Dialysis': Icons.water_drop,
    'Emergency': Icons.crisis_alert,
    'Physiotherapy': Icons.sports_gymnastics,
    'X-Ray': Icons.radio,
    'MRI': Icons.biotech,
    'CT Scan': Icons.scanner,
    'NICU': Icons.child_care,
    'PICU': Icons.child_friendly,
    'Vaccination': Icons.vaccines,
    'Cath Lab': Icons.favorite,
    'Echocardiography': Icons.monitor_heart,
    'PFT Lab': Icons.air,
    'Bronchoscopy': Icons.track_changes,
    'Sleep Lab': Icons.bedtime,
    'Labour Room': Icons.pregnant_woman,
    'Ultrasound': Icons.waves,
    'Endoscopy Suite': Icons.settings_input_svideo,
    'Liver Lab': Icons.science,
    'Lithotripsy': Icons.flash_on,
    'DEXA Scan': Icons.image,
    'Rehabilitation': Icons.accessibility_new,
  };

  Widget _buildFacilitiesSection(HospitalModel hospital) {
    return _sectionCard(
      title: 'Facilities',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.8,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: hospital.facilities.length,
        itemBuilder: (context, i) {
          final facility = hospital.facilities[i];
          final icon = _facilityIcons[facility] ?? Icons.check_circle_outline;
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    facility,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Doctors Carousel ──────────────────────────────────────────────────────
  Widget _buildDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              const Text(
                'Doctors',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) {
            if (state is DoctorLoading || state is DoctorInitial) {
              return _buildDoctorShimmer();
            }
            if (state is DoctorLoaded) {
              final docs = _filterDoctors(state.doctors);
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'No doctors listed for this hospital yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                );
              }
              return _buildDoctorCarousel(docs);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildDoctorCarousel(List<DoctorModel> doctors) {
    final single = doctors.length == 1;
    return Column(
      children: [
        SizedBox(
          height: 165,
          child: single
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildDoctorCard(doctors.first),
                )
              : PageView.builder(
                  controller: _doctorPageController,
                  itemCount: doctors.length,
                  onPageChanged: (i) =>
                      setState(() => _currentDoctorPage = i),
                  itemBuilder: (ctx, i) => Padding(
                    padding: EdgeInsets.only(
                      left: i == 0 ? 20 : 8,
                      right: i == doctors.length - 1 ? 20 : 8,
                    ),
                    child: _buildDoctorCard(doctors[i]),
                  ),
                ),
        ),
        if (!single) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              doctors.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentDoctorPage ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _currentDoctorPage
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return GestureDetector(
      onTap: () => _showDoctorBottomSheet(doctor),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    doctor.specializations.join(', '),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${doctor.experienceYears} yrs exp  •  ₹${doctor.consultationFee.toInt()}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${doctor.rating} (${doctor.reviewsCount})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE0E0E0),
        highlightColor: const Color(0xFFF5F5F5),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ── Doctor Bottom Sheet ───────────────────────────────────────────────────
  void _showDoctorBottomSheet(DoctorModel doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DoctorBottomSheet(doctor: doctor),
    );
  }

  // ── Map Placeholder ───────────────────────────────────────────────────────
  Widget _buildMapPlaceholder(HospitalModel hospital) {
    return _sectionCard(
      title: 'Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Simulated map grid lines
                  CustomPaint(
                    size: const Size(double.infinity, 150),
                    painter: _MapGridPainter(),
                  ),
                  // Pin icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.location_pin,
                        color: Colors.redAccent, size: 28),
                  ),
                  // Open Maps overlay
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final lat = hospital.geoPoint.latitude;
                        final lng = hospital.geoPoint.longitude;
                        final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open maps')));
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_new, size: 14),
                      label: const Text('Open Maps',
                          style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hospital.address,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Lat: ${hospital.geoPoint.latitude.toStringAsFixed(4)}, Lng: ${hospital.geoPoint.longitude.toStringAsFixed(4)}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ── Booking Bar ───────────────────────────────────────────────────────────
  Widget _buildBookingBar(HospitalModel hospital) {
    final isOPD = _isMultiSpecialty;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOPD ? 'OPD Consultation' : 'Direct Consultation',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    isOPD
                        ? 'General → Referred to specialist'
                        : 'Book directly with specialist',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                final doctorState = context.read<DoctorBloc>().state;
                if (doctorState is DoctorLoaded) {
                  final hospitalDoctors = doctorState.doctors
                      .where((d) => d.hospitalId == hospital.id)
                      .toList();
                  if (hospitalDoctors.isNotEmpty) {
                    if (hospitalDoctors.length == 1 || !isOPD) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AppointmentBookingSheet(
                          doctor: hospitalDoctors.first, 
                          hospital: hospital,
                          onBookingSuccess: (appointment) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Appointment Booked! Token: ${appointment.tokenNumber}'),
                                backgroundColor: Colors.green,
                                action: SnackBarAction(
                                  label: 'View Queue',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    context.pushNamed('hospitalsQueue', extra: appointment);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a specialist from the Doctors list above to book.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 52),
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isOPD ? 'Book OPD' : 'Book Now',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Doctor Bottom Sheet Widget ────────────────────────────────────────────────
class _DoctorBottomSheet extends StatelessWidget {
  final DoctorModel doctor;

  const _DoctorBottomSheet({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Doctor header
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 38),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      doctor.specializations.join(' • '),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 13, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          '${doctor.rating} (${doctor.reviewsCount} reviews)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Info chips row
          Row(
            children: [
              _infoPill(
                Icons.work_outline,
                '${doctor.experienceYears} yrs',
                AppColors.primary,
              ),
              const SizedBox(width: 8),
              _infoPill(
                Icons.currency_rupee,
                '₹${doctor.consultationFee.toInt()} fee',
                Colors.green,
              ),
              const SizedBox(width: 8),
              _infoPill(
                Icons.language,
                doctor.languages.first,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Qualifications
          _detailRow(
            'Qualifications',
            doctor.qualifications.join(', '),
          ),
          const Divider(height: 20),

          // Available slots
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Available Slots',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: doctor.availabilitySlots.map((slot) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
                child: Text(
                  slot,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.chat);
                  },
                  icon: const Icon(Icons.chat_bubble_outline,
                      size: 18, color: AppColors.primary),
                  label: const Text(
                    'Chat',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // close doctor info sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AppointmentBookingSheet(
                        doctor: doctor,
                        onBookingSuccess: (appointment) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Appointment Booked! Token: ${appointment.tokenNumber}'),
                              backgroundColor: Colors.green,
                              action: SnackBarAction(
                                label: 'View Queue',
                                textColor: Colors.white,
                                onPressed: () {
                                  context.pushNamed('hospitalsQueue', extra: appointment);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month,
                      size: 18, color: Colors.white),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Book Appointment',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

// ── Map Grid Painter ──────────────────────────────────────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Simulated roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.4),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.3, 0),
        Offset(size.width * 0.3, size.height),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.7, 0),
        Offset(size.width * 0.7, size.height),
        roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
