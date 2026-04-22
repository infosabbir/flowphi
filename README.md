# FlowPhi

FlowPhi is a personal finance Flutter app for tracking income, expenses, and money you have lent to others. It combines Firebase Authentication for sign-in and Drift for local data storage, with Riverpod managing app state across the dashboard and auth flow.

## Features

- Email/password authentication with Firebase
- Login, registration, logout, and password reset flow
- Dashboard summary for income, expenses, and current balance
- Period-based filtering for daily, weekly, and monthly views
- Add and manage income entries
- Add and manage expense entries
- Track active loans and mark them as completed
- Sort expense summaries by date or amount
- Device Preview enabled during development

## Tech Stack

- Flutter
- Dart
- Riverpod
- Firebase Core
- Firebase Auth
- Drift
- Intl
- Google Fonts

## Project Structure

```text
lib/
  app/
    app.dart
  core/
    custom_appbar.dart
    theme/
  features/
    auth/
      data/
      presentation/
    dashboard/
      presentation/
        providers/
        widgets/
    expense/
      data/
        drift/
```

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK installed
- A configured Firebase project
- Android Studio, VS Code, or another Flutter-ready IDE

### Setup

1. Clone the repository.
2. Install dependencies:

```bash
flutter pub get
```

3. Make sure Firebase is configured for your target platform.
   The app initializes Firebase in `lib/main.dart` using `lib/firebase_options.dart`.
4. Run the app:

```bash
flutter run
```

## Database

FlowPhi uses Drift for local persistence. The current database tables are:

- `expenses`
- `income`
- `loans`

Generated Drift code lives in [lib/features/expense/data/drift/app_database.g.dart](/e:/FlutterDev/flowphi/lib/features/expense/data/drift/app_database.g.dart).

If you change Drift table definitions, regenerate code with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Authentication Flow

- Unauthenticated users are routed to the login screen.
- Authenticated users are routed to the dashboard.
- Firebase Authentication is used for register, login, logout, and password reset.

The auth gate is implemented in [lib/features/auth/presentation/auth_gate.dart](/e:/FlutterDev/flowphi/lib/features/auth/presentation/auth_gate.dart).

## Main Screens

- Login and registration screens
- Forgot password screen
- Dashboard with summary cards
- Transaction bottom sheet for adding income, expense, and loan entries
- Loan management section

## Useful Commands

```bash
flutter pub get
flutter run
dart analyze
dart run build_runner build --delete-conflicting-outputs
flutter test
```

## Notes

- Package name: `flow_phi`
- App title: `FlowPhi`
- Material Design is enabled
- App icon assets are stored in `assets/icon/`

## Future Improvements

- Edit and delete support for expenses from the dashboard
- Better validation and input formatting for currency fields
- Charts and analytics views
- Export and backup options
- Improved test coverage

## License

This project is currently private and not published to pub.dev.
