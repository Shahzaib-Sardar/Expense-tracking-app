# Expense Tracking App

Expense Tracking App is a Flutter application for personal finance management with Firebase Authentication and local SQLite storage.

## Features

- Firebase Authentication (signup/login)
- Expense and income tracking with SQLite
- Monthly budget setup and overspending alerts
- Transaction history and filtering
- Profile management
- Visual dashboard and charts

## Secure Configuration (Required)

This project is configured to avoid committing secrets.

1. Copy `.env.example` to `.env`.
2. Fill `.env` with your real Firebase values.
3. Keep `.env` private. It is ignored by Git.

Minimal example:

```env
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_APP_ID_ANDROID=your_android_app_id
FIREBASE_APP_ID_IOS=your_ios_app_id
FIREBASE_APP_ID_MACOS=your_macos_app_id
FIREBASE_APP_ID_WEB=your_web_app_id
FIREBASE_IOS_BUNDLE_ID=com.example.app
FIREBASE_MACOS_BUNDLE_ID=com.example.app
```

## Run Safely

Install dependencies:

```bash
flutter pub get
```

Run with local `.env` values:

```bash
flutter run
```

Run with secure CI or temporary overrides using `--dart-define`:

```bash
flutter run \
	--dart-define=FIREBASE_API_KEY=your_api_key \
	--dart-define=FIREBASE_PROJECT_ID=your_project_id \
	--dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
	--dart-define=FIREBASE_STORAGE_BUCKET=your_storage_bucket \
	--dart-define=FIREBASE_AUTH_DOMAIN=your_auth_domain \
	--dart-define=FIREBASE_APP_ID_ANDROID=your_android_app_id \
	--dart-define=FIREBASE_APP_ID_IOS=your_ios_app_id \
	--dart-define=FIREBASE_APP_ID_MACOS=your_macos_app_id \
	--dart-define=FIREBASE_APP_ID_WEB=your_web_app_id \
	--dart-define=FIREBASE_IOS_BUNDLE_ID=com.example.app \
	--dart-define=FIREBASE_MACOS_BUNDLE_ID=com.example.app
```

Build release safely:

```bash
flutter build apk --release --dart-define-from-file=.env
```

## Contribution and Testing (No Secret Leaks)

- Never commit `.env`, API keys, tokens, or private keys.
- Before opening a PR, search staged files for likely secrets.
- Use placeholder values in examples and docs.

Recommended local checks:

```bash
flutter analyze
flutter test
git diff --cached | rg -i "api[_-]?key|token|secret|private[_-]?key|AIza"
```

## Suggested Structure for Secrets Separation

Use this pattern to keep source code public-safe:

```text
lib/
	config/
		app_env.dart            # runtime env resolver (tracked)
		firebase_options.dart   # reads from env only (tracked)
.env.example                # placeholders only (tracked)
.env                        # real secrets (ignored)
android/app/google-services.json      # local only (ignored, if needed)
ios/Runner/GoogleService-Info.plist   # local only (ignored, if needed)
```

## Internship / LinkedIn Presentation Tips

- Add polished screenshots in a folder like `assets/previews/`.
- Include one short demo GIF of onboarding, adding expense, and dashboard update.
- Show one architecture image (Auth flow + SQLite + UI pages).
- Add a short "Security Improvements" section in your post:
	- moved secrets to runtime env
	- removed committed credentials
	- added safe contribution workflow

## Pre-Commit Advice

Set a local Git hook path and add a secret-scan hook before each commit:

```bash
git config core.hooksPath .githooks
```

Then create `.githooks/pre-commit` to run a staged secret scan and block unsafe commits.

