import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message, {this.cause});
  final String message;
  final Object? cause;
  @override
  List<Object?> get props => [message, cause];
}

final class PreferenceFailure extends Failure {
  const PreferenceFailure(super.message, {super.cause});
}
