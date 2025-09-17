# VoiceNote Project

A voice recording and transcription application built with Flutter and Python.

## Features

- **Voice Recording**: Capture audio with high quality
- **Speech-to-Text**: Convert voice recordings to text using ASR models
- **Text-to-Speech**: Convert text back to speech using TTS models
- **User Authentication**: Secure login and signup system
- **Cross-Platform**: Works on Android, iOS, and Web

## Tech Stack

- **Frontend**: Flutter/Dart
- **Backend**: Python
- **Authentication**: Firebase Auth
- **Voice Processing**: Custom ASR and TTS models

## Project Structure

```
voicenote-project/
├── voicenote_app/          # Flutter application
│   ├── lib/                # Dart source code
│   │   └── screens/        # App screens
│   └── pubspec.yaml        # Flutter dependencies
├── voicenote_project/      # Python backend
├── asr_model.py           # Speech-to-text model
└── tts_model.py           # Text-to-speech model
```

## Getting Started

### Prerequisites

- Flutter SDK
- Python 3.8+
- Firebase project setup

### Installation

1. Clone the repository:
```bash
git clone https://github.com/ceyddari/voicenote_project.git
cd voicenote_project
```

2. Install Flutter dependencies:
```bash
cd voicenote_app
flutter pub get
```

3. Install Python dependencies:
```bash
pip install -r requirements.txt
```

4. Run the Flutter app:
```bash
flutter run
```


## License

This project is licensed under the MIT License.
