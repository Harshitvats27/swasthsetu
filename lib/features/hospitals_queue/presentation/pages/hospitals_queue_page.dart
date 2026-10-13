import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';
import 'package:swasthsetu/features/appointments/data/models/appointment_model.dart';
import 'package:swasthsetu/features/hospitals_queue/bloc/hospitals_queue_bloc.dart';

class HospitalsQueuePage extends StatefulWidget {
  final AppointmentModel? appointment;

  const HospitalsQueuePage({super.key, this.appointment});

  @override
  State<HospitalsQueuePage> createState() => _HospitalsQueuePageState();
}

class _HospitalsQueuePageState extends State<HospitalsQueuePage> {
  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      final isOpd = widget.appointment!.bookingType == 'OPD';
      final entityId = isOpd && widget.appointment!.hospitalId != null && widget.appointment!.hospitalId!.isNotEmpty
          ? widget.appointment!.hospitalId!
          : widget.appointment!.doctorId;

      context.read<HospitalsQueueBloc>().add(
        SubscribeToQueueEvent(
          doctorId: entityId,
          date: widget.appointment!.date,
          userTokenNumber: widget.appointment!.tokenNumber,
        )
      );
    }
  }

  @override
  void dispose() {
    // Unsubscribe when leaving the page (optional, as Bloc might handle it, but good practice)
    // Actually, we don't need to manually dispatch if Bloc is provided at route level and closed automatically
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Queue')),
        body: const Center(child: Text('Invalid appointment details.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Live Queue Status', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: BlocBuilder<HospitalsQueueBloc, HospitalsQueueState>(
        builder: (context, state) {
          if (state is HospitalsQueueLoading || state is HospitalsQueueInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HospitalsQueueError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is HospitalsQueueLive) {
            final int patientsAhead = state.patientsAhead > 0 ? state.patientsAhead : 0;
            final int waitTime = state.estimatedWaitTimeMinutes > 0 ? state.estimatedWaitTimeMinutes : 0;
            final bool isYourTurn = state.patientsAhead <= 0;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('Your Token', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                          Text(
                            '${widget.appointment!.tokenNumber}',
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (isYourTurn)
                      const Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 64),
                          SizedBox(height: 16),
                          Text(
                            'It\'s your turn!',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          SizedBox(height: 8),
                          Text('Please proceed to the doctor\'s cabin.', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 24),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Patients Ahead', '$patientsAhead', Icons.people),
                        _buildStatCard('Est. Wait Time', '$waitTime min', Icons.timer),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Currently Serving: Token ${state.queueModel.currentTokenServing}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
