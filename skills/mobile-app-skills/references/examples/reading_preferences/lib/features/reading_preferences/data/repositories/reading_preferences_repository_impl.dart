import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/reading_preferences_repository.dart';
import '../datasources/reading_preferences_local_data_source.dart';

final class ReadingPreferencesRepositoryImpl
    implements ReadingPreferencesRepository {
  const ReadingPreferencesRepositoryImpl(this.source);
  final ReadingPreferencesLocalDataSource source;

  @override
  Future<Either<Failure, bool>> loadKeepAwake() async {
    try {
      final result = await source.readKeepAwake();
      return result.fold<Either<Failure, bool>>(
        onSuccess: (stored) => Right(stored ?? false),
        onFailure:
            (error) => Left(
              PreferenceFailure(
                'Could not load reading settings.',
                cause: error,
              ),
            ),
      );
    } on Object catch (error) {
      return Left(
        PreferenceFailure('Could not load reading settings.', cause: error),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> saveKeepAwake(bool enabled) async {
    try {
      final result = await source.writeKeepAwake(enabled);
      return result.fold<Either<Failure, bool>>(
        onSuccess: (_) => Right(enabled),
        onFailure:
            (error) => Left(
              PreferenceFailure(
                'Could not save reading settings.',
                cause: error,
              ),
            ),
      );
    } on Object catch (error) {
      return Left(
        PreferenceFailure('Could not save reading settings.', cause: error),
      );
    }
  }
}
