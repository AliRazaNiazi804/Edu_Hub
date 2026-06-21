# My App Flutter Project

## Overview

`my_app` is a starter Flutter project for the university mobile app assignment. It includes a clean folder structure, essential dependencies, and placeholders for API keys.

## Folder Structure

```
my_app/
├─ lib/
│  ├─ screens/      # UI screens (pages)
│  ├─ widgets/      # Re‑usable widgets
│  ├─ models/       # Data models
│  ├─ services/     # Business logic / API services
│  ├─ utils/        # Helper classes (e.g., secrets.dart)
│  └─ main.dart
├─ test/            # Unit & widget tests
├─ .env             # Environment variables (git‑ignored)
└─ pubspec.yaml
```

## Setup Instructions

1. **Prerequisites**
   - Install the latest Flutter SDK ([flutter.dev](https://flutter.dev)).
   - Ensure an Android emulator or a physical device is connected.
2. **Clone the repo** (if applicable) and navigate to the project directory:
   ```bash
   cd my_app
   ```
3. **Install dependencies**
   ```bash
   flutter pub get
   ```
4. **Add your API keys**
   - Create a file named `.env` in the project root (it is already added to `.gitignore`).
   - Add your keys, e.g.:
     ```env
     API_KEY=your_api_key_here
     FIREBASE_API_KEY=your_firebase_key_here
     ```
   - The `Secrets` class in `lib/utils/secrets.dart` shows how to access them via `flutter_dotenv` or a custom loader.
5. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

- **State Management**: `provider`
- **HTTP**: `http`
- **Local Storage**: `shared_preferences`, `sqflite`, `path`
- **Internationalization**: `intl`
- **Notifications**: `flutter_local_notifications`
- **Image Picker** (optional): `image_picker`

## Getting an API Key

- **REST API**: Register at the service provider’s developer portal and copy the key into `.env` as `API_KEY`.
- **Firebase**: Follow the Firebase console setup for Android/iOS, then add `FIREBASE_API_KEY` to `.env`.

## Notes

- Do **not** commit `.env` or any real secrets to version control.
- You can extend the folder structure as the project grows.
- For additional configuration, refer to the Flutter documentation.
