import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/features/sos/bloc/sos_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SosBottomSheet extends StatelessWidget {
  const SosBottomSheet({super.key});

  void _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  Widget _buildEmergencyCard(
    BuildContext context, 
    String title, 
    String subtitle, 
    String number, 
    Color startColor, 
    Color endColor, 
    IconData icon
  ) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        boxShadow: [
          BoxShadow(
            color: endColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _callNumber(number),
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call, color: endColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        number,
                        style: TextStyle(
                          color: endColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.emergency.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.health_and_safety, color: AppColors.emergency, size: 30),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.black87, 
                          letterSpacing: -0.5
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Tap a card to call instantly',
                        style: TextStyle(
                          fontSize: 13, 
                          color: Colors.black54, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emergency.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.sos, color: Colors.white, size: 20),
                    label: const Text(
                      'SOS', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1
                      )
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      backgroundColor: AppColors.emergency,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      context.read<SosBloc>().add(TriggerSosEmergency());
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 24, right: 8, bottom: 24),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildEmergencyCard(
                  context, 
                  'Police', 
                  'Immediate assistance', 
                  '100', 
                  const Color(0xFF4CA1AF), 
                  const Color(0xFF2C3E50), 
                  Icons.local_police
                ),
                _buildEmergencyCard(
                  context, 
                  'Ambulance', 
                  'Medical emergency', 
                  '108', 
                  const Color(0xFFFF416C), 
                  const Color(0xFFFF4B2B), 
                  Icons.medical_services
                ),
                _buildEmergencyCard(
                  context, 
                  'General', 
                  'All emergencies', 
                  '112', 
                  const Color(0xFFF2994A), 
                  const Color(0xFFF2C94C), 
                  Icons.phone_in_talk
                ),
                _buildEmergencyCard(
                  context, 
                  'Women', 
                  'Women Helpline', 
                  '1091', 
                  const Color(0xFFDA4453), 
                  const Color(0xFF89216B), 
                  Icons.female
                ),
                _buildEmergencyCard(
                  context, 
                  'Highway', 
                  'Highway Helpline', 
                  '1033', 
                  const Color(0xFF11998E), 
                  const Color(0xFF38EF7D), 
                  Icons.directions_car
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
