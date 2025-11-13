# User Flow Diagram

Home → STT → Text → TTS → Voice select → Output → Save/Download

## 1. Home Screen

- User sees buttons for "Speech to Text", "Text to Speech", "History", and "Settings".

## 2. Speech to Text (STT)

- User taps on "Speech to Text".
- User taps on "Start Recording" to start recording their voice.
- User taps on "Stop Recording" to stop the recording.
- The app sends the recorded audio to the ElevenLabs API.
- The transcribed text is displayed on the screen.
- The transcription is saved to the history.

## 3. Text to Speech (TTS)

- User taps on "Text to Speech".
- User enters text in the text field.
- User taps on "Select Voice" to choose a voice.
- The app displays a list of available voices.
- User selects a voice.
- User taps on "Convert to Speech".
- The app sends the text and selected voice to the ElevenLabs API.
- The generated audio is played automatically.
- The TTS conversion is saved to the history.
- User can download the audio file.

## 4. History

- User taps on "History".
- The app displays the STT and TTS history in separate tabs.

## 5. Settings

- User taps on "Settings".
- The app displays options to change the language and default voice.
