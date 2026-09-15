import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../../domain/usecases/reading_preferences_usecases.dart';

sealed class ReadingPreferencesEvent {
  const ReadingPreferencesEvent();
}

final class ReadingPreferencesOpened extends ReadingPreferencesEvent {
  const ReadingPreferencesOpened();
}

final class KeepAwakeChanged extends ReadingPreferencesEvent {
  const KeepAwakeChanged(this.enabled);
  final bool enabled;
}

final class ReadingPreferencesState extends Equatable {
  const ReadingPreferencesState({
    this.keepAwake,
    this.busy = false,
    this.error,
  });
  // Null means not loaded. False is a real saved/default value.
  final bool? keepAwake;
  final bool busy;
  final String? error;

  @override
  List<Object?> get props => [keepAwake, busy, error];
}

final class ReadingPreferencesBloc
    extends Bloc<ReadingPreferencesEvent, ReadingPreferencesState> {
  ReadingPreferencesBloc({required this.load, required this.save})
    : super(const ReadingPreferencesState()) {
    on<ReadingPreferencesOpened>((event, emit) async {
      if (state.busy) return;
      final previous = state.keepAwake;
      emit(ReadingPreferencesState(keepAwake: previous, busy: true));
      final result = await load(const NoParams());
      if (emit.isDone) return;
      result.fold(
        (failure) => emit(
          ReadingPreferencesState(keepAwake: previous, error: failure.message),
        ),
        (value) => emit(ReadingPreferencesState(keepAwake: value)),
      );
    });
    on<KeepAwakeChanged>((event, emit) async {
      if (state.busy || state.keepAwake == null) return;
      final previous = state.keepAwake;
      emit(ReadingPreferencesState(keepAwake: previous, busy: true));
      final result = await save(event.enabled);
      if (emit.isDone) return;
      result.fold(
        (failure) => emit(
          ReadingPreferencesState(keepAwake: previous, error: failure.message),
        ),
        (value) => emit(ReadingPreferencesState(keepAwake: value)),
      );
    });
  }
  final LoadKeepAwake load;
  final SaveKeepAwake save;
}
