
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:text_speech_app/l10n/app_localizations.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/stt'),
              child: Text(AppLocalizations.of(context)!.speechToText),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/tts'),
              child: Text(AppLocalizations.of(context)!.textToSpeech),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/history'),
              child: Text(AppLocalizations.of(context)!.history),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/settings'),
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
