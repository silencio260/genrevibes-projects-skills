import 'package:dartz/dartz.dart';
import '../error/failure.dart';

abstract class BaseUseCase<Output, Input> {
  const BaseUseCase();
  Future<Either<Failure, Output>> call(Input params);
}

final class NoParams {
  const NoParams();
}
