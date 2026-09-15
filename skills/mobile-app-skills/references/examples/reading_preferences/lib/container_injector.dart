import 'package:get_it/get_it.dart';
import 'package:genrevibes_storage/genrevibes_storage.dart';
import 'features/reading_preferences/reading_preferences_injector.dart';

// Isolated so the example does not reuse Story Saver's container if imported.
final GetIt sl = GetIt.asNewInstance();
void registerExampleDependencies(KeyValueStore store) {
  sl.registerSingleton<KeyValueStore>(store);
  registerReadingPreferences(sl);
}
