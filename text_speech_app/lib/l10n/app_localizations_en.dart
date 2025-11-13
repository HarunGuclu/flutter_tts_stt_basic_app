// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Text Speech App';

  @override
  String get speechToText => 'Speech to Text';

  @override
  String get textToSpeech => 'Text to Speech';

  @override
  String get history => 'History';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get enterText => 'Enter your text';

  @override
  String get selectVoice => 'Select Voice';

  @override
  String get convertToSpeech => 'Convert to Speech';

  @override
  String get sttHistory => 'STT History';

  @override
  String get ttsHistory => 'TTS History';

  @override
  String get selectFile => 'Select File';

  @override
String get clearHistory => 'Clear History';

@override
String get clearHistoryConfirmation => 'Are you sure you want to clear all history?';

@override
String get cancel => 'Cancel';

@override
String get clear => 'Clear';

}
