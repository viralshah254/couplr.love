# Security & penetration-surface notes

- **Secrets**: No API keys or secrets in source. Use env (e.g. `flutter_dotenv`) and never commit `.env` with real keys.
- **Auth**: Auth is mock for now; production must use secure tokens (e.g. Firebase Auth, secure storage).
- **Network**: Use HTTPS only for all API calls. Validate certificates.
- **Data**: Sensitive data (e.g. journal) should be encrypted at rest when backed by real storage.
- **Input**: Validate and sanitize all user input; avoid passing raw input to shell or native code.
- **Crash reporting**: Bootstrap wires `FlutterError.onError` and `runZonedGuarded` to logging; can be extended to a crash reporting service (e.g. Firebase Crashlytics).
- **Deletion**: Destructive actions use confirmation dialogs; journal delete is implemented as a reference.
