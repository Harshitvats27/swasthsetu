import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';
import 'package:swasthsetu/features/appointments/bloc/appointments_bloc.dart';
import 'package:swasthsetu/features/profile/bloc/profile_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swasthsetu/core/di/injection_container.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      context.read<AppointmentsBloc>().add(LoadUserAppointmentsEvent(patientId: profileState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, profileState) {
        if (profileState is ProfileLoaded) {
          context.read<AppointmentsBloc>().add(LoadUserAppointmentsEvent(patientId: profileState.user.uid));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          title: const Text('My Appointments', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
          builder: (context, state) {
            if (state is AppointmentsLoading) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              );
            } else if (state is AppointmentsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is AppointmentsLoaded) {
              final appointments = state.appointments;
              if (appointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('No appointments yet', style: AppTextStyles.headlineMedium),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  final isToday = appt.date == DateFormat('yyyy-MM-dd').format(DateTime.now());
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.white, const Color(0xFFF8FAFC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Date/Time and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text('${appt.date} • ${appt.slot}', style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: appt.status == 'cancelled' ? Colors.red.shade50 : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: appt.status == 'cancelled' ? Colors.red.shade200 : Colors.green.shade200),
                                ),
                                child: Text(
                                  appt.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: appt.status == 'cancelled' ? Colors.red.shade700 : Colors.green.shade700,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
                          
                          // Middle Row: Doctor Info and Token
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.person, color: AppColors.primary, size: 32),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Dr. ${appt.doctorName.isNotEmpty ? appt.doctorName : 'Unknown'}', 
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.local_hospital, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            appt.hospitalName.isNotEmpty ? appt.hospitalName : 'Not Specified',
                                            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Token Box
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Text('TOKEN', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                    const SizedBox(height: 2),
                                    Text('${appt.tokenNumber}', style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Actions: Chat & Navigate
                          if (appt.status != 'cancelled') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat coming soon!')));
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                    label: const Text('Chat'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      try {
                                        double? lat;
                                        double? lng;
                                        
                                        if (appt.hospitalId != null && appt.hospitalId!.isNotEmpty) {
                                          final doc = await sl<FirebaseFirestore>().collection('hospitals').doc(appt.hospitalId).get();
                                          if (doc.exists && doc.data()!.containsKey('geoPoint')) {
                                            final geo = doc['geoPoint'] as GeoPoint;
                                            lat = geo.latitude;
                                            lng = geo.longitude;
                                          }
                                        } else {
                                          final doc = await sl<FirebaseFirestore>().collection('doctors').doc(appt.doctorId).get();
                                          if (doc.exists && doc.data()!.containsKey('geoPoint')) {
                                            final geo = doc['geoPoint'] as GeoPoint;
                                            lat = geo.latitude;
                                            lng = geo.longitude;
                                          }
                                        }

                                        if (lat != null && lng != null) {
                                          final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open maps')));
                                            }
                                          }
                                        } else {
                                          // Fallback to name search if geoPoint not found
                                          final target = appt.hospitalName.isNotEmpty ? appt.hospitalName : appt.doctorName;
                                          final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(target)}');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.directions, size: 18),
                                    label: const Text('Navigate'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Actions: Live Queue & Cancel
                            Row(
                              children: [
                                if (isToday)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => context.pushNamed('hospitalsQueue', extra: appt),
                                      icon: const Icon(Icons.live_tv, size: 18, color: Colors.white),
                                      label: const Text('Live Queue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: null,
                                      icon: const Icon(Icons.live_tv, size: 18),
                                      label: const Text('Live Queue'),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => context.read<AppointmentsBloc>().add(CancelAppointmentEvent(appointmentId: appt.id)),
                                    icon: const Icon(Icons.cancel_outlined, size: 18),
                                    label: const Text('Cancel'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red.shade600,
                                      side: BorderSide(color: Colors.red.shade200),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Please wait...'));
          },
        ),
      ),
    );
  }
}
