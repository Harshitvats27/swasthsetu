import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/router/app_routes.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_bloc.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_event.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_state.dart';
import 'package:swasthsetu/features/doctors/data/models/doctor_model.dart';
import 'package:swasthsetu/features/appointments/presentation/widgets/appointment_booking_sheet.dart';
class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key, this.initialSpecialty});

  final String? initialSpecialty;

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _activeSpecialty;

  @override
  void initState() {
    super.initState();
    _applySpecialty(widget.initialSpecialty);
  }

  @override
  void didUpdateWidget(covariant DoctorsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSpecialty != oldWidget.initialSpecialty) {
      _applySpecialty(widget.initialSpecialty);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySpecialty(String? specialty) {
    if (specialty != null && specialty.trim().isNotEmpty) {
      final trimmed = specialty.trim();
      _activeSpecialty = trimmed;
      _searchController.text = trimmed;
      context.read<DoctorBloc>().add(SearchDoctorsEvent(trimmed));
    } else {
      _activeSpecialty = null;
      _searchController.clear();
      context.read<DoctorBloc>().add(LoadDoctorsEvent());
    }
  }

  void _onSearchChanged(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() => _activeSpecialty = null);
      context.read<DoctorBloc>().add(LoadDoctorsEvent());
    } else {
      setState(() => _activeSpecialty = trimmed);
      context.read<DoctorBloc>().add(SearchDoctorsEvent(trimmed));
    }
  }

  void _clearFilter() {
    _searchController.clear();
    setState(() => _activeSpecialty = null);
    context.read<DoctorBloc>().add(LoadDoctorsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    final canPop = router?.canPop() ?? Navigator.of(context).canPop();
    final hasSpecialty = _activeSpecialty != null && _activeSpecialty!.isNotEmpty;

    void handleBack() {
      if (router != null && router.canPop()) {
        context.pop();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go(AppRoutes.home);
      }
    }

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          title: const Text('Find Doctors', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          leading: (canPop || hasSpecialty)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: handleBack,
                )
              : null,
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: BlocBuilder<DoctorBloc, DoctorState>(
                builder: (context, state) {
                  if (state is DoctorLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DoctorLoaded) {
                    if (state.doctors.isEmpty) {
                      return const Center(child: Text('No doctors found.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.doctors.length,
                      itemBuilder: (context, index) {
                        return _buildDoctorCard(state.doctors[index]);
                      },
                    );
                  } else if (state is DoctorError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text('Please wait...'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by name, specialty...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: _clearFilter,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF0F2F5),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final hasSpecialty = _activeSpecialty != null && _activeSpecialty!.isNotEmpty;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(
            hasSpecialty ? 'Specialty: $_activeSpecialty' : 'Specialty',
            isSelected: hasSpecialty,
            onTap: hasSpecialty ? _clearFilter : null,
          ),
          const SizedBox(width: 8),
          _buildChip('Distance'),
          const SizedBox(width: 8),
          _buildChip('Language'),
          const SizedBox(width: 8),
          _buildChip('Fee'),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return ActionChip(
      avatar: isSelected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isSelected ? Icons.close_rounded : Icons.arrow_drop_down,
            size: 16,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ],
      ),
      onPressed: onTap ?? () {
        // Implement filter modal here
      },
      backgroundColor: isSelected ? AppColors.primary : const Color(0xFFF0F2F5),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: doctor.profilePictureUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: doctor.profilePictureUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Icon(Icons.person, size: 40, color: Colors.grey),
                        errorWidget: (context, url, error) => const Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                    )
                  : const Center(child: Icon(Icons.person, size: 40, color: Colors.grey)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specializations.join(', '),
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctor.clinicName,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.payments, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '₹ ${doctor.consultationFee.toInt()}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 2),
                      Text(
                        '${doctor.rating} (${doctor.reviewsCount})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
