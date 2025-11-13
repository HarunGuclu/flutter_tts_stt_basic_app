class Transcription {
  final String text;
  final String? transcriptionId;

  Transcription({required this.text, this.transcriptionId});

  factory Transcription.fromJson(Map<String, dynamic> json) {
    return Transcription(
      text: json['text'] as String,
      transcriptionId: json['transcription_id'] as String?,
    );
  }
}
