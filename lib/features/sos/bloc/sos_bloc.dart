import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:shake/shake.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swasthsetu/core/di/injection_container.dart';

part 'sos_event.dart';
part 'sos_state.dart';

class SosBloc extends Bloc<SosEvent, SosState> {
  ShakeDetector? _shakeDetector;
  Timer? _countdownTimer;
  int _secondsLeft = 5;

  SosBloc() : super(SosInitial()) {
    on<StartSosListening>(_onStartListening);
    on<StopSosListening>(_onStopListening);
    on<TriggerSosEmergency>(_onTriggerEmergency);
    on<CancelSosEmergency>(_onCancelEmergency);
    on<_TickSosCountdown>(_onTickCountdown);
    on<_ExecuteSos>(_onExecuteSos);
  }

  void _onStartListening(StartSosListening event, Emitter<SosState> emit) {
    if (_shakeDetector != null) return;
    
    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 5,
      minimumShakeCount: 2,
      onPhoneShake: (event) {
        add(TriggerSosEmergency());
      },
    );
    emit(SosListening());
  }

  void _onStopListening(StopSosListening event, Emitter<SosState> emit) {
    _shakeDetector?.stopListening();
    _shakeDetector = null;
    emit(SosInitial());
  }

  void _onTriggerEmergency(TriggerSosEmergency event, Emitter<SosState> emit) {
    if (state is SosCountdown || state is SosTriggered) return;
    
    HapticFeedback.heavyImpact();
    _secondsLeft = 5;
    emit(SosCountdown(_secondsLeft));
    
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        _secondsLeft--;
        add(_TickSosCountdown(_secondsLeft));
      } else {
        timer.cancel();
        add(_ExecuteSos());
      }
    });
  }

  void _onTickCountdown(_TickSosCountdown event, Emitter<SosState> emit) {
    if (state is SosCountdown) {
      emit(SosCountdown(event.secondsLeft));
    }
  }

  void _onCancelEmergency(CancelSosEmergency event, Emitter<SosState> emit) {
    _countdownTimer?.cancel();
    emit(SosListening());
  }

  Future<void> _onExecuteSos(_ExecuteSos event, Emitter<SosState> emit) async {
    emit(SosTriggered());
    HapticFeedback.vibrate();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        emit(const SosError('User not logged in'));
        return;
      }

      final doc = await sl<FirebaseFirestore>().collection('users').doc(uid).get();
      if (!doc.exists || !doc.data()!.containsKey('emergencyContacts')) {
        emit(const SosError('No emergency contacts found'));
        return;
      }

      final contactsData = doc.data()!['emergencyContacts'] as List<dynamic>?;
      if (contactsData == null || contactsData.isEmpty) {
        emit(const SosError('No emergency contacts found'));
        return;
      }

      final contacts = contactsData.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      Future.delayed(Duration.zero, () async {
        for (var contact in contacts) {
          final phone = contact['phone']?.toString().replaceAll(RegExp(r'\s+'), "") ?? '';
          if (phone.isNotEmpty) {
            FlutterPhoneDirectCaller.callNumber(phone);
            await Future.delayed(const Duration(seconds: 30));
          }
        }
      });

      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 4),
            );
          }
        }
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      String locationLink = position != null 
          ? "https://maps.google.com/?q=${position.latitude},${position.longitude}"
          : "Location unavailable.";
      String message = "🚨 EMERGENCY! I need help. Track my live location here:\n $locationLink ";
      
      String separator = Platform.isAndroid ? ';' : ',';
      String allNumbers = contacts.map((c) => (c['phone']?.toString().replaceAll(RegExp(r'\s+'), "") ?? '')).where((s) => s.isNotEmpty).join(separator);

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: allNumbers,
        queryParameters: {'body': message},
      );

      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      
      await Future.delayed(const Duration(seconds: 3));
      emit(SosListening());
      
    } catch (e) {
      emit(SosError(e.toString()));
      emit(SosListening());
    }
  }

  @override
  Future<void> close() {
    _shakeDetector?.stopListening();
    _countdownTimer?.cancel();
    return super.close();
  }
}
