import 'package:flutter/material.dart';
import 'package:genrevibes_storage_shared_preferences/genrevibes_storage_shared_preferences.dart';
import 'config/routes_manager.dart';
import 'container_injector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerExampleDependencies(SharedPreferencesKeyValueStore());
  runApp(const ReadingExampleApp());
}

class ReadingExampleApp extends StatelessWidget {
  const ReadingExampleApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Reading preferences example',
    initialRoute: Routes.readingPreferences,
    onGenerateRoute: buildRoute,
  );
}
