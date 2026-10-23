import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swasthsetu/core/router/app_routes.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/features/profile/bloc/profile_bloc.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_bloc.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_state.dart';
import 'package:swasthsetu/features/doctors/data/models/doctor_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swasthsetu/core/di/injection_container.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';
import 'package:swasthsetu/core/widgets/widgets.dart';
import 'package:swasthsetu/features/appointments/presentation/widgets/appointment_booking_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Light background
      floatingActionButton: FloatingActionButton(
        heroTag: 'populate_hospitals_fab',
        onPressed: () async {
          final firestore = sl<FirebaseFirestore>();
          final hospitalsSnapshot = await firestore.collection('hospitals').get();
          final doctorsSnapshot = await firestore.collection('doctors').get();
          
          if (hospitalsSnapshot.docs.isEmpty || doctorsSnapshot.docs.isEmpty) {
            print("No hospitals or doctors found.");
            return;
          }
          
          List<DocumentSnapshot> doctors = doctorsSnapshot.docs.toList();
          doctors.shuffle();
          int docIndex = 0;
          
          for (var hospital in hospitalsSnapshot.docs) {
            final data = hospital.data();
            final totalBeds = data['totalBeds'] ?? 0;
            
            // Big hospital (>= 100 beds) -> 5 to 6 doctors
            // Medium (30-99 beds) -> 3 to 4 doctors
            // Small (< 30 beds) -> 1 to 2 doctors
            int doctorsCount = 1;
            if (totalBeds >= 100) {
              doctorsCount = 5;
            } else if (totalBeds >= 30) {
              doctorsCount = 3;
            } else {
              doctorsCount = 1;
            }
            
            List<String> assignedDoctorIds = [];
            for (int i = 0; i < doctorsCount; i++) {
              if (docIndex >= doctors.length) {
                // loop around if not enough doctors
                docIndex = 0;
                doctors.shuffle();
              }
              final docId = doctors[docIndex].id;
              assignedDoctorIds.add(docId);
              
              // Update doctor to have this hospitalId and isHospital=true
              await firestore.collection('doctors').doc(docId).update({
                'hospitalId': hospital.id,
                'isHospital': true,
                'clinicName': data['name'], // optionally set clinicName to hospital name
              });
              
              docIndex++;
            }
            
            // Update hospital with doctorIds
            await firestore.collection('hospitals').doc(hospital.id).update({
              'doctorIds': assignedDoctorIds,
            });
            
            print("Updated hospital ${hospital.id} with ${assignedDoctorIds.length} doctors.");
          }
          print("DONE POPULATING");
        },
        child: const Icon(Icons.build),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildBannerCarousel(),
                  const SizedBox(height: 24),
                  _buildDoctorsSection(context),
                  const SizedBox(height: 24),
                  _buildHealthPromoBanner(context),
                  const SizedBox(height: 24),
                  _buildFirstActionCard(context),
                  const SizedBox(height: 24),
                  _buildSecondActionCard(context),
                  const SizedBox(height: 32),
                  _buildFooterSection(),
                ],
              ),
            ),
            // Floating Bot Icon for AI Search
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'ai_search_fab',
                onPressed: () => context.push(AppRoutes.aiSearch),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.smart_toy, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String name = 'Guest User';
        if (state is ProfileLoaded) {
          name = state.user.name ?? 'Guest User';
        } else if (state is ProfileSaved) {
          name = state.user.name ?? 'Guest User';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A8BBD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => context.push(AppRoutes.patientDetails),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Change Profile', style: TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerCarousel() {
    return StreamBuilder<QuerySnapshot>(
      stream: sl<FirebaseFirestore>().collection('banners').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final bannerDocs = snapshot.data!.docs;

        return CarouselSlider(
          options: CarouselOptions(
            height: 160.0,
            autoPlay: bannerDocs.length > 1,
            enableInfiniteScroll: bannerDocs.length > 1,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            aspectRatio: 16 / 9,
            initialPage: 0,
          ),
          items: bannerDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final imageUrl = data['imageUrl'] ?? data['image'] ?? '';
            final link = data['link'] ?? '';

            return Builder(
              builder: (BuildContext context) {
                return InkWell(
                  onTap: link.isNotEmpty ? () => _launchURL(link) : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            )
                          : const Center(child: Text('No Image', style: TextStyle(color: Colors.grey))),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        _buildAnimatedQuotesBox(),
        const SizedBox(height: 24),
        _buildContactSection(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAnimatedQuotesBox() {
    final List<String> quotes = [
      "\"Health is not valued till sickness comes.\"",
      "\"A healthy outside starts from the inside.\"",
      "\"Take care of your body. It's the only place you have to live.\"",
      "\"The greatest wealth is health.\"",
      "\"Let food be thy medicine and medicine be thy food.\"",
      "\"Your body hears everything your mind says.\"",
      "\"An apple a day keeps the doctor away.\"",
      "\"Prevention is better than cure.\"",
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.format_quote, color: AppColors.primary.withOpacity(0.6), size: 28),
              const SizedBox(width: 8),
              const Text('Daily Health Wisdom', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          CarouselSlider(
            options: CarouselOptions(
              height: 80.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeInOut,
              viewportFraction: 1.0,
            ),
            items: quotes.map((quote) {
              return Center(
                child: Text(
                  quote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
    }
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency & Contact',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildEmergencyCard(
                title: 'Ambulance',
                subtitle: '108',
                icon: Icons.medical_services,
                color: Colors.redAccent,
                onTap: () => _launchURL('tel:108'),
              ),
              const SizedBox(width: 12),
              _buildEmergencyCard(
                title: 'Police',
                subtitle: '100',
                icon: Icons.local_police,
                color: Colors.blueAccent,
                onTap: () => _launchURL('tel:100'),
              ),
              const SizedBox(width: 12),
              _buildEmergencyCard(
                title: 'National',
                subtitle: '112',
                icon: Icons.sos,
                color: Colors.orangeAccent,
                onTap: () => _launchURL('tel:112'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEmailCard(),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailCard() {
    return InkWell(
      onTap: () => _launchURL('mailto:swasthsethu@gmail.com'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8)],
              ),
              child: const Icon(Icons.email_outlined, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Send us a Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                  SizedBox(height: 4),
                  Text('swasthsethu@gmail.com', style: TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Our Doctors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.doctors),
                child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: BlocBuilder<DoctorBloc, DoctorState>(
            builder: (context, state) {
              if (state is DoctorLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DoctorLoaded) {
                if (state.doctors.isEmpty) {
                  return const Center(child: Text('No doctors available.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.doctors.length,
                  itemBuilder: (context, index) {
                    final doc = state.doctors[index];
                    return _buildDoctorCard(doc);
                  },
                );
              } else if (state is DoctorError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('Loading doctors...'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          // Doctor Image
          Container(
            width: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            child: doctor.profilePictureUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: doctor.profilePictureUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Icon(Icons.person, size: 50, color: Colors.grey),
                      errorWidget: (context, url, error) => const Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                  )
                : const Center(child: Icon(Icons.person, size: 50, color: Colors.grey)),
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specializations.join(', '),
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Consultation Fee ₹ ${doctor.consultationFee.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text(
                        'Book Appointment',
                        style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPromoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppCard(
        onTap: () => context.push(AppRoutes.healthCheck),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.pastelMint,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.monitor_heart_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Check your health in 1 minute',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            PillButton.navy(
              text: 'Start',
              width: 82,
              height: 36,
              showTrailingArrow: true,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              onPressed: () => context.push(AppRoutes.healthCheck),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstActionCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: [
            PastelIconTile(
              backgroundColor: AppColors.pastelBlue,
              label: 'Appointment',
              icon: Icons.calendar_month,
              circleSize: 60,
              iconSize: 26,
              onTap: () => context.push(AppRoutes.appointments),
            ),
            PastelIconTile(
              backgroundColor: AppColors.pastelPink,
              label: 'Medication',
              icon: Icons.medication,
              circleSize: 60,
              iconSize: 26,
              onTap: () async {
                final url = Uri.parse('https://grabkrt.web.app/');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch URL')),
                    );
                  }
                }
              },
            ),
            const PastelIconTile(
              backgroundColor: AppColors.pastelCyan,
              label: 'Diagnosis',
              icon: Icons.monitor_heart,
              circleSize: 60,
              iconSize: 26,
            ),
            const PastelIconTile(
              backgroundColor: AppColors.pastelOrange,
              label: 'Follow Up',
              icon: Icons.assignment,
              circleSize: 60,
              iconSize: 26,
            ),
            const PastelIconTile(
              backgroundColor: AppColors.pastelGreen,
              label: 'Allergies',
              icon: Icons.back_hand,
              circleSize: 60,
              iconSize: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondActionCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: [
            const PastelIconTile(
              backgroundColor: AppColors.pastelBlue,
              label: 'Pathology Reports',
              icon: Icons.article_outlined,
              circleSize: 60,
              iconSize: 26,
            ),
            const PastelIconTile(
              backgroundColor: AppColors.pastelPink,
              label: 'Radiology Reports',
              icon: Icons.medical_services_outlined,
              circleSize: 60,
              iconSize: 26,
            ),
            const PastelIconTile(
              backgroundColor: AppColors.pastelPurple,
              label: 'Health Records',
              icon: Icons.folder_shared_outlined,
              circleSize: 60,
              iconSize: 26,
            ),
            const PastelIconTile(
              backgroundColor: AppColors.pastelOrange,
              label: 'My Ledger',
              icon: Icons.receipt_long_outlined,
              circleSize: 60,
              iconSize: 26,
            ),
            const PastelIconTile(
              backgroundColor: AppColors.pastelCyan,
              label: 'Discharge Summary',
              icon: Icons.assignment_outlined,
              circleSize: 60,
              iconSize: 26,
            ),
            PastelIconTile(
              backgroundColor: AppColors.pastelMint,
              label: 'Health Check',
              icon: Icons.monitor_heart_rounded,
              circleSize: 60,
              iconSize: 26,
              onTap: () => context.push(AppRoutes.healthCheck),
            ),
          ],
        ),
      ),
    );
  }
}

