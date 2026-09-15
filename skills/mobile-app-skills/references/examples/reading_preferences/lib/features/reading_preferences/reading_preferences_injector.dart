import 'package:get_it/get_it.dart';
import 'package:genrevibes_storage/genrevibes_storage.dart';
import 'data/datasources/reading_preferences_local_data_source.dart';
import 'data/repositories/reading_preferences_repository_impl.dart';
import 'domain/repositories/reading_preferences_repository.dart';
import 'domain/usecases/reading_preferences_usecases.dart';
import 'presentation/bloc/reading_preferences_bloc.dart';

void registerReadingPreferences(GetIt sl) {
  sl.registerLazySingleton(
    () => ReadingPreferencesLocalDataSource(sl<KeyValueStore>()),
  );
  sl.registerLazySingleton<ReadingPreferencesRepository>(
    () => ReadingPreferencesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => LoadKeepAwake(sl()));
  sl.registerLazySingleton(() => SaveKeepAwake(sl()));
  sl.registerFactory(() => ReadingPreferencesBloc(load: sl(), save: sl()));
}
