# Pet Records Hub

A cross-platform Flutter application for managing pet-care records. The app brings pet, pet owner, veterinarian, and vaccination information into one local mobile experience with persistent storage and English/French localization.

## Key features

- Create, view, update, and delete pet-care records
- Separate modules for pets, owners, veterinarians, and vaccinations
- Local persistence using Floor and SQLite
- Encrypted storage for reusable form information
- English and Canadian French localization
- Input validation, confirmation dialogs, snackbars, and contextual instructions
- Android, iOS, web, Windows, macOS, and Linux project targets

## Technology

- Flutter and Dart
- Floor ORM and SQLite
- Encrypted Shared Preferences
- Flutter localization
- Material Design

## My contribution

I developed the veterinarian module and supported integration of the team's application. My work included:

- Designing the veterinarian entity and DAO
- Implementing database-backed CRUD operations
- Building form validation and record-selection workflows
- Adding update and delete confirmations
- Saving and restoring previously entered veterinarian information
- Supporting English and French UI text
- Documenting the module and assisting with final integration

## Project structure

```text
lib/
|- main.dart                  # Application entry point and module navigation
|- app_database.dart          # Floor database configuration
|- app_localizations.dart     # Localization loader and delegate
|- pet_page.dart              # Pet record workflows
|- PetOwnerListPage.dart      # Pet owner workflows
|- veterinarian_page.dart     # Veterinarian workflows
|- vaccine_page.dart          # Vaccination workflows
`- *_dao.dart / entities      # Persistence layer
```

## Run locally

### Prerequisites

- Flutter SDK compatible with Dart `^3.10.0`
- A configured Android emulator, physical device, or supported desktop/web target

### Setup

```bash
git clone https://github.com/wassilymp/cst2335_final_project.git
cd cst2335_final_project
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Screenshots

Screenshots of the home screen and veterinarian CRUD workflow will be added here.

## Team project note

This application was completed as an academic team project. The repository contains work from multiple contributors; individual module ownership is identified in the application and summarized above.
