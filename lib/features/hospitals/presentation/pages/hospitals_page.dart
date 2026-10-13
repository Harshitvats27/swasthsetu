import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/features/hospitals/bloc/hospital_bloc.dart';
import 'package:swasthsetu/features/hospitals/bloc/hospital_event.dart';
import 'package:swasthsetu/features/hospitals/bloc/hospital_state.dart';
import 'package:swasthsetu/features/hospitals/data/models/hospital_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<HospitalModel> _allHospitals = [];
  List<HospitalModel> _filtered = [];
  
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _showMap = false;
  bool _limitRadius = true; // Limits to 100km radius by default
  
  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    context.read<HospitalBloc>().add(LoadHospitalsEvent());
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoadingLocation = false);
      return;
    } 

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLoadingLocation = false;
    });
    _applyFilters();
  }

  void _onSearch(String query) {
    // If they explicitly search for "near me", we use the radius limit
    // If they search for a specific city, we don't force the radius limit 
    // so they can see hospitals far away (like searching "Delhi" from "Mumbai").
    if (query.isNotEmpty && query.toLowerCase() != 'near me') {
      _limitRadius = false;
    } else {
      _limitRadius = true;
    }
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      final q = _searchController.text.toLowerCase().trim();
      
      _filtered = _allHospitals.where((h) {
        bool matchesSearch = true;
        
        if (q.isNotEmpty && q != 'near me') {
          matchesSearch = h.name.toLowerCase().contains(q) ||
              h.city.toLowerCase().contains(q) ||
              h.specialties.any((s) => s.toLowerCase().contains(q));
        }
        
        bool withinRadius = true;
        if (_limitRadius && _currentPosition != null) {
          // This is where the 100km logic is written
          final distanceInMeters = Geolocator.distanceBetween(
            _currentPosition!.latitude, 
            _currentPosition!.longitude, 
            h.geoPoint.latitude, 
            h.geoPoint.longitude,
          );
          // 100 km = 100,000 meters
          withinRadius = distanceInMeters <= 100000;
        }

        return matchesSearch && withinRadius;
      }).toList();

      // Sort by distance if location available
      if (_currentPosition != null) {
        _filtered.sort((a, b) {
           final distA = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, a.geoPoint.latitude, a.geoPoint.longitude);
           final distB = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, b.geoPoint.latitude, b.geoPoint.longitude);
           return distA.compareTo(distB);
        });
      }
      
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    _markers.clear();
    for (var h in _filtered) {
      _markers.add(
        Marker(
          markerId: MarkerId(h.id),
          position: LatLng(h.geoPoint.latitude, h.geoPoint.longitude),
          infoWindow: InfoWindow(
            title: h.name,
            snippet: h.city,
            onTap: () {
              context.go('/hospitals/${h.id}');
            }
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Hospitals',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterControls(),
          Expanded(
            child: BlocConsumer<HospitalBloc, HospitalState>(
              listener: (context, state) {
                if (state is HospitalSeeded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Hospitals seeded to Firebase!'), backgroundColor: Colors.green),
                  );
                  context.read<HospitalBloc>().add(LoadHospitalsEvent());
                } else if (state is HospitalLoaded) {
                  _allHospitals = state.hospitals;
                  _applyFilters(); // Filter handles sorting and markers too
                }
              },
              builder: (context, state) {
                if (state is HospitalLoading || state is HospitalInitial || _isLoadingLocation) {
                  return _buildShimmer();
                } else if (state is HospitalLoaded || state is HospitalError) {
                  if (state is HospitalError) {
                    return _buildError(state.message);
                  }
                  
                  return _showMap ? _buildMapView() : _buildListView();
                }
                return _buildShimmer();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Near Me (100km)'),
            selected: _limitRadius,
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            checkmarkColor: AppColors.primary,
            onSelected: (val) {
              setState(() {
                _limitRadius = val;
                if (val && _searchController.text.isNotEmpty && _searchController.text.toLowerCase() != 'near me') {
                    _searchController.clear();
                }
                _applyFilters();
              });
            },
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
            icon: Icon(_showMap ? Icons.list : Icons.map, color: AppColors.primary),
            label: Text(_showMap ? 'List View' : 'Map View', style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    final initialCameraPosition = _currentPosition != null
        ? CameraPosition(target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), zoom: 12)
        : const CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5); // India center

    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
    );
  }

  Widget _buildListView() {
    if (_filtered.isEmpty) {
      return _buildEmpty();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: _filtered.length,
      itemBuilder: (context, index) => _buildHospitalCard(_filtered[index]),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search "near me" or "Delhi", "Dental"...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF0F2F5),
        ),
      ),
    );
  }

  Widget _buildHospitalCard(HospitalModel hospital) {
    String distanceStr = '';
    if (_currentPosition != null) {
      double dist = Geolocator.distanceBetween(
        _currentPosition!.latitude, 
        _currentPosition!.longitude, 
        hospital.geoPoint.latitude, 
        hospital.geoPoint.longitude
      );
      if (dist < 1000) {
        distanceStr = '${dist.round()} m away';
      } else {
        distanceStr = '${(dist/1000).toStringAsFixed(1)} km away';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top gradient header with hospital icon
          Container(
            height: 90,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.local_hospital, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hospital.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 13),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    '${hospital.city}, ${hospital.state}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (hospital.isOpen24x7)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('24×7', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details section
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Online Booking Badge
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text('Online Booking Available', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (distanceStr.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.route, size: 14, color: Colors.blue.shade600),
                          const SizedBox(width: 4),
                          Text(distanceStr, style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place_outlined, size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hospital.address,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Beds & Rating row
                Row(
                  children: [
                    const Icon(Icons.bed, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${hospital.totalBeds} Beds', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 3),
                    Text('${hospital.rating} (${hospital.reviewsCount})', style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    const Icon(Icons.phone_outlined, size: 14, color: Colors.green),
                    const SizedBox(width: 3),
                    Text(hospital.phone, style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 10),

                // Specialties chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: hospital.specialties.take(4).map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(s, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Directions + View Details buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final lat = hospital.geoPoint.latitude;
                          final lng = hospital.geoPoint.longitude;
                          final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open maps')));
                          }
                        },
                        icon: const Icon(Icons.directions, size: 15, color: AppColors.primary),
                        label: const Text('Directions', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/hospitals/${hospital.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('View Details', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: 5,
      itemBuilder: (context, _) => Shimmer.fromColors(
        baseColor: const Color(0xFFE0E0E0),
        highlightColor: const Color(0xFFF5F5F5),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 90, decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(18)))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(w: double.infinity, h: 12),
                    const SizedBox(height: 8),
                    _shimmerBox(w: 200, h: 12),
                    const SizedBox(height: 10),
                    Row(children: [_shimmerBox(w: 80, h: 10), const SizedBox(width: 12), _shimmerBox(w: 80, h: 10)]),
                    const SizedBox(height: 10),
                    Row(children: [_shimmerBox(w: 60, h: 22), const SizedBox(width: 6), _shimmerBox(w: 80, h: 22)]),
                    const SizedBox(height: 12),
                    Row(children: [Expanded(child: _shimmerBox(w: double.infinity, h: 36)), const SizedBox(width: 10), Expanded(child: _shimmerBox(w: double.infinity, h: 36))]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox({required double w, required double h}) {
    return Container(width: w, height: h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)));
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_hospital_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No hospitals found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
          SizedBox(height: 8),
          Text('Try searching or changing radius', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<HospitalBloc>().add(LoadHospitalsEvent()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
