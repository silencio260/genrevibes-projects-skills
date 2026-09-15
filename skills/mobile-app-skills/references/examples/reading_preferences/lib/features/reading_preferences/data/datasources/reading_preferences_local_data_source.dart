import 'package:genrevibes_core/genrevibes_core.dart';
import 'package:genrevibes_storage/genrevibes_storage.dart';

final class ReadingPreferencesLocalDataSource {
  const ReadingPreferencesLocalDataSource(this.store);
  final KeyValueStore store;
  static const keepAwakeKey = 'app.reading.keep_awake.v1';

  Future<KitResult<bool?>> readKeepAwake() => store.getBool(keepAwakeKey);
  Future<KitResult<void>> writeKeepAwake(bool enabled) =>
      store.setBool(keepAwakeKey, enabled);
}
