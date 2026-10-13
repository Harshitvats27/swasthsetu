import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/features/appointments/bloc/appointments_bloc.dart';
import 'package:swasthsetu/features/appointments/data/models/appointment_model.dart';
import 'package:swasthsetu/features/doctors/data/models/doctor_model.dart';
import 'package:swasthsetu/features/hospitals/data/models/hospital_model.dart';
import 'package:swasthsetu/features/profile/bloc/profile_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/router/app_routes.dart';
class AppointmentBookingSheet extends StatefulWidget {
  final DoctorModel doctor;
  final HospitalModel? hospital;

  final void Function(AppointmentModel) onBookingSuccess;

  const AppointmentBookingSheet({
    super.key,
    required this.doctor,
    this.hospital,
    required this.onBookingSuccess,
  });

  @override
  State<AppointmentBookingSheet> createState() => _AppointmentBookingSheetState();
}

class _AppointmentBookingSheetState extends State<AppointmentBookingSheet> {
  DateTime selectedDate = DateTime.now();
  String? selectedSlot;

  @override
  Widget build(BuildContext context) {
    final bool isOpd = widget.doctor.isHospital;
    final String bookingType = isOpd ? 'OPD' : 'CLINIC';
    
    return BlocConsumer<AppointmentsBloc, AppointmentsState>(
      listener: (context, state) {
        if (state is AppointmentBookingSuccess) {
          Navigator.pop(context); // Close sheet
          widget.onBookingSuccess(state.appointment);
        } else if (state is AppointmentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AppointmentsLoading) {
          return Container(
            height: 300,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const CircularProgressIndicator(),
          );
        }

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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

              Text(
                isOpd ? 'Register for OPD' : 'Book Clinic Appointment',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dr. ${widget.doctor.name}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 32),

              // Date Selector
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = DateTime.now().add(Duration(days: index));
                    final isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month;
                    
                    final dayNameFull = DateFormat('EEEE').format(date);
                    final isAvailable = widget.doctor.availableDays.contains(dayNameFull) && !widget.doctor.daysOff.contains(dayNameFull);
                    
                    return GestureDetector(
                      onTap: isAvailable ? () {
                        setState(() {
                          selectedDate = date;
                          selectedSlot = null; // reset slot on date change
                        });
                      } : null,
                      child: Opacity(
                        opacity: isAvailable ? 1.0 : 0.4,
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Slot Selector
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Slot',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              widget.doctor.availabilitySlots.isEmpty
                  ? const Text('No slots available.')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: widget.doctor.availabilitySlots.map((slot) {
                        final isSelected = slot == selectedSlot;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSlot = slot;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary,
                              ),
                            ),
                            child: Text(
                              slot,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 32),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedSlot == null
                      ? null
                      : () {
                          // Get patient ID
                          final profileState =
                              context.read<ProfileBloc>().state;
                          if (profileState is ProfileLoaded) {
                            final appointment = AppointmentModel(
                              id: '',
                              patientId: profileState.user.uid,
                              doctorId: widget.doctor.id,
                              hospitalId: widget.hospital?.id ?? widget.doctor.hospitalId,
                              doctorName: widget.doctor.name,
                              hospitalName: widget.hospital?.name ?? widget.doctor.clinicName,
                              date: DateFormat('yyyy-MM-dd').format(selectedDate),
                              slot: selectedSlot!,
                              tokenNumber: 0, // will be generated
                              status: 'scheduled',
                              bookingType: bookingType,
                              timestamp: DateTime.now(),
                            );
                            
                            context.read<AppointmentsBloc>().add(
                                BookAppointmentEvent(
                                    appointment: appointment));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error: Patient Profile not loaded.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirm ${isOpd ? 'OPD Registration' : 'Booking'}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
