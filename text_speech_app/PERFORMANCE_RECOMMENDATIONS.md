# Performance Recommendations

## 1. Background Processing for Large Audio Files

For large audio files, especially in the Speech-to-Text (STT) process, consider using a background isolate to handle the API request and file processing. This will prevent the UI from freezing during the operation.

- Use the `Isolate` class from `dart:isolate`.
- Pass the audio file path to the isolate.
- The isolate will then make the API request and return the result to the main thread.

## 2. File Cleanup Cron Job

The application stores audio files for both STT and TTS history. To prevent the app from taking up too much storage, implement a file cleanup mechanism.

- Create a "cron job" that runs periodically (e.g., once a day).
- This job will check for old audio files in the app's directory.
- Files that are older than a certain period (e.g., 30 days) and are not part of the history can be deleted.

## 3. Lazy-Loaded Lists

For the history screen, use lazy-loaded lists to improve performance. Instead of loading all the history records at once, load them in batches as the user scrolls.

- Use a `ListView.builder` with a `ScrollController`.
- When the user scrolls to the end of the list, fetch the next batch of history records from the database.
