import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/reading_preferences_repository.dart';

final class LoadKeepAwake extends BaseUseCase<bool, NoParams> {
  const LoadKeepAwake(this.repository);
  final ReadingPreferencesRepository repository;
  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      repository.loadKeepAwake();
}

final class SaveKeepAwake extends BaseUseCase<bool, bool> {
  const SaveKeepAwake(this.repository);
  final ReadingPreferencesRepository repository;
  @override
  Future<Either<Failure, bool>> call(bool enabled) =>
      repository.saveKeepAwake(enabled);
}
