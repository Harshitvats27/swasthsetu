import 'package:dartz/dartz.dart';
import 'package:swasthsetu/core/errors/failures.dart';
import 'package:swasthsetu/features/hospitals/data/datasources/hospital_remote_datasource.dart';
import 'package:swasthsetu/features/hospitals/data/models/hospital_model.dart';

class HospitalRepository {
  final HospitalRemoteDataSource remote;

  HospitalRepository({required this.remote});

  Future<Either<Failure, List<HospitalModel>>> getHospitals() async {
    try {
      final hospitals = await remote.fetchHospitals();
      return Right(hospitals);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> seedHospitals() async {
    try {
      await remote.seedHospitals();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
