import 'package:dartz/dartz.dart';
import 'package:swasthsetu/core/errors/failures.dart';
import 'package:swasthsetu/features/doctors/data/datasources/doctor_remote_datasource.dart';
import 'package:swasthsetu/features/doctors/data/models/doctor_model.dart';

class DoctorRepository {
  final DoctorRemoteDataSource remote;

  DoctorRepository({required this.remote});

  Future<Either<Failure, List<DoctorModel>>> getDoctors() async {
    try {
      final doctors = await remote.fetchDoctors();
      return Right(doctors);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<DoctorModel>>> searchDoctors(String query) async {
    try {
      final doctors = await remote.searchDoctors(query);
      return Right(doctors);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
