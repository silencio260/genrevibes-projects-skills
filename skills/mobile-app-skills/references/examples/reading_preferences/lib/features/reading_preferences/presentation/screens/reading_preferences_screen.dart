import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reading_preferences_bloc.dart';

class ReadingPreferencesScreen extends StatelessWidget {
  const ReadingPreferencesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reading settings')),
    body: BlocBuilder<ReadingPreferencesBloc, ReadingPreferencesState>(
      builder:
          (context, state) => ListView(
            children: [
              if (state.busy) const LinearProgressIndicator(),
              if (state.keepAwake != null)
                SwitchListTile(
                  title: const Text('Keep screen awake'),
                  subtitle: const Text(
                    'Preference example; does not control the device screen.',
                  ),
                  value: state.keepAwake!,
                  onChanged:
                      state.busy
                          ? null
                          : (value) => context
                              .read<ReadingPreferencesBloc>()
                              .add(KeepAwakeChanged(value)),
                ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(state.error!),
                ),
              if (state.keepAwake == null && !state.busy)
                TextButton(
                  onPressed:
                      () => context.read<ReadingPreferencesBloc>().add(
                        const ReadingPreferencesOpened(),
                      ),
                  child: const Text('Retry loading'),
                ),
            ],
          ),
    ),
  );
}
