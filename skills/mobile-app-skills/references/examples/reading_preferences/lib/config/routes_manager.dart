import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../container_injector.dart';
import '../features/reading_preferences/presentation/bloc/reading_preferences_bloc.dart';
import '../features/reading_preferences/presentation/screens/reading_preferences_screen.dart';

abstract final class Routes {
  static const readingPreferences = '/';
}

Route<void> buildRoute(RouteSettings settings) {
  if (settings.name == Routes.readingPreferences) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder:
          (_) => BlocProvider(
            create:
                (_) =>
                    sl<ReadingPreferencesBloc>()
                      ..add(const ReadingPreferencesOpened()),
            child: const ReadingPreferencesScreen(),
          ),
    );
  }
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))),
  );
}
