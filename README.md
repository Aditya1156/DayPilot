# DayPilot (Flutter)

This workspace contains a starter Flutter app scaffold for "DayPilot" — an AI-powered daily routine and reminder app. The app includes initial UI screens, theme, and local/Hive initialization. Firebase is attempted during startup but is optional for early development.

Quick start (Windows PowerShell):

```powershell
# From the project root
flutter pub get
flutter run
```

Notes & next steps:

- Firebase: to enable push notifications, auth and Firestore, add platform-specific Firebase configuration files (GoogleService-Info.plist for iOS, google-services.json for Android) and follow the FlutterFire CLI setup.
- AI Integration: the project includes placeholders for AI screens. Implement a backend (FastAPI / NestJS) and call OpenAI/GPT endpoints or LangChain services.
- Notifications: use `flutter_local_notifications` and `firebase_messaging` to support local and remote notifications.

Files added/changed:
- `lib/main.dart` — initializes Hive and registers routes
- `lib/screens/*` — scaffold screens for Routine Builder, AI Optimization, Reminders, Analytics, Chat Assistant
- `lib/providers/app_providers.dart` — example Riverpod providers

If you'd like, I can:
- Generate a visual architecture diagram (PNG/SVG) showing Flutter frontend, Firebase, AI backend, and notification flow.
- Implement one feature end-to-end (e.g., add task creation with Hive persistence and local notifications).
