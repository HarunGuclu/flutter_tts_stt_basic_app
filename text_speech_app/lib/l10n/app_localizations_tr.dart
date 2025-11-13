// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Ses-Metin Uygulaması';

  @override
  String get speechToText => 'Sesi Metne Çevir';

  @override
  String get textToSpeech => 'Metni Sese Çevir';

  @override
  String get history => 'Geçmiş';

  @override
  String get startRecording => 'Kaydı Başlat';

  @override
  String get stopRecording => 'Kaydı Durdur';

  @override
  String get enterText => 'Metni girin';

  @override
  String get selectVoice => 'Ses Seç';

  @override
  String get convertToSpeech => 'Sese Dönüştür';

  @override
  String get sttHistory => 'STT Geçmişi';

  @override
  String get ttsHistory => 'TTS Geçmişi';

  @override
  String get selectFile => 'Dosya Seç';

  @override
String get clearHistory => 'Geçmişi Sil';

@override
String get clearHistoryConfirmation => 'Tüm geçmişi silmek istediğinizden emin misiniz?';

@override
String get cancel => 'İptal';

@override
String get clear => 'Sil';

}
