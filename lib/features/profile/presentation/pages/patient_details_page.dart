import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/router/app_routes.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:swasthsetu/core/theme/app_text_styles.dart';
import 'package:swasthsetu/features/auth/bloc/auth_bloc.dart';
import 'package:swasthsetu/features/profile/bloc/profile_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:permission_handler/permission_handler.dart';

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({super.key});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _allergiesController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedGender;
  final List<Map<String, dynamic>> _emergencyContacts = [];
  bool _isEditMode = true;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      String? uid;
      bool isComplete = false;
      
      if (authState is AuthAuthenticated) {
        uid = authState.userId;
        isComplete = authState.isProfileComplete;
      } else if (authState is NewUserRegistered) {
        uid = authState.userId;
      }
      
      if (uid != null) {
        _isEditMode = !isComplete;
        setState(() {});
        context.read<ProfileBloc>().add(LoadProfileEvent(uid: uid));
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  void _onSave(String uid) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(SaveProfileEvent(
        uid: uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        bloodGroup: _selectedBloodGroup,
        age: int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        height: double.tryParse(_heightController.text.trim()),
        weight: double.tryParse(_weightController.text.trim()),
        existingConditions: _conditionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        allergies: _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        emergencyContacts: _emergencyContacts,
      ));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        final age = DateTime.now().year - picked.year;
        _ageController.text = age.toString();
      });
    }
  }

  Future<void> _pickContact() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        final selectedContact = await FlutterContacts.native.showPicker(properties: {ContactProperty.phone});
        
        if (selectedContact != null && selectedContact.phones.isNotEmpty) {
          setState(() {
            _emergencyContacts.add({
              'name': selectedContact.displayName,
              'phone': selectedContact.phones.first.number,
            });
          });
        } else if (selectedContact != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact has no phone number')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts: $e')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission denied')),
      );
    }
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: 6,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String uid = '';
    if (authState is AuthAuthenticated) uid = authState.userId;
    if (authState is NewUserRegistered) uid = authState.userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Patient Details' : 'Patient Details'),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.primary,
        ),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => setState(() => _isEditMode = true),
            ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile saved successfully')),
            );
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProfileLoaded) {
            final user = state.user;
            _nameController.text = user.name ?? '';
            _emailController.text = user.email ?? '';
            _dobController.text = user.dateOfBirth ?? '';
            _ageController.text = user.age?.toString() ?? '';
            _heightController.text = user.height?.toString() ?? '';
            _weightController.text = user.weight?.toString() ?? '';
            _conditionsController.text = user.existingConditions?.join(', ') ?? '';
            _allergiesController.text = user.allergies?.join(', ') ?? '';
            
            if (_bloodGroups.contains(user.bloodGroup)) {
              _selectedBloodGroup = user.bloodGroup;
            }
            if (_genders.contains(user.gender)) {
              _selectedGender = user.gender;
            }
            
            _emergencyContacts.clear();
            if (user.emergencyContacts != null) {
              _emergencyContacts.addAll(user.emergencyContacts!);
            }
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && state is! ProfileLoaded) {
            return _buildShimmer();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Basic Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditMode,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _dobController,
                          enabled: _isEditMode,
                          readOnly: true,
                          onTap: _isEditMode ? () => _selectDate(context) : null,
                          decoration: InputDecoration(
                            labelText: 'DOB',
                            prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          enabled: _isEditMode,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.people_outline, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: _isEditMode ? (val) => setState(() => _selectedGender = val) : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBloodGroup,
                    decoration: InputDecoration(
                      labelText: 'Blood Group',
                      prefixIcon: const Icon(Icons.bloodtype_outlined, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                    onChanged: _isEditMode ? (val) => setState(() => _selectedBloodGroup = val) : null,
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('Vitals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          enabled: _isEditMode,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            prefixIcon: const Icon(Icons.height, color: AppColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          enabled: _isEditMode,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            prefixIcon: const Icon(Icons.scale, color: AppColors.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('Medical History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _conditionsController,
                    enabled: _isEditMode,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Existing Conditions (comma separated)',
                      prefixIcon: const Icon(Icons.medical_services_outlined, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _allergiesController,
                    enabled: _isEditMode,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Allergies (comma separated)',
                      prefixIcon: const Icon(Icons.warning_amber_outlined, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Emergency Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      if (_isEditMode)
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                          onPressed: _pickContact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_emergencyContacts.isEmpty)
                    const Text('No emergency contacts added.', style: TextStyle(color: Colors.grey))
                  else
                    ..._emergencyContacts.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final contact = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.iconBlue, 
                            child: Icon(Icons.person, color: AppColors.primary)
                          ),
                          title: Text(contact['name'] ?? ''),
                          subtitle: Text(contact['phone'] ?? ''),
                          trailing: _isEditMode ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _emergencyContacts.removeAt(idx);
                              });
                            },
                          ) : null,
                        ),
                      );
                    }),

                  const SizedBox(height: 48),
                  if (_isEditMode)
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state is ProfileLoading ? null : () => _onSave(uid),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 0,
                        ),
                        child: state is ProfileLoading
                            ? const CircularProgressIndicator(color: AppColors.white)
                            : Text('Save Details', style: AppTextStyles.buttonLabel.copyWith(color: AppColors.white)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
