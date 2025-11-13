import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:text_speech_app/screens/home_screen.dart';
import 'package:text_speech_app/screens/stt_screen.dart';
import 'package:text_speech_app/screens/tts_screen.dart';
import 'package:text_speech_app/screens/voice_selection_screen.dart';

import 'package:text_speech_app/screens/history_screen.dart';

import 'package:text_speech_app/screens/settings_screen.dart';
import 'package:text_speech_app/db/database_service.dart';
import 'l10n/app_localizations.dart';


Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final languageCode = await DatabaseService.instance.getSetting('language');
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/stt',
      builder: (context, state) => const SttScreen(),
    ),
    GoRoute(
      path: '/tts',
      builder: (context, state) => const TtsScreen(),
    ),
    GoRoute(
      path: '/voice-selection',
      builder: (context, state) => const VoiceSelectionScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);