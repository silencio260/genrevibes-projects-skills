import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';

abstract interface class ReadingPreferencesRepository {
  Future<Either<Failure, bool>> loadKeepAwake();
  Future<Either<Failure, bool>> saveKeepAwake(bool enabled);
}
