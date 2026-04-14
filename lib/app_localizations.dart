import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Loads language strings from JSON translation files.
class AppLocalizations {
  /// The locale currently in use.
  final Locale locale;

  /// Creates a localization instance for the given locale.
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  late Map<String, String> _localizedStrings;

  /// Loads the matching JSON file for the current locale.
  Future<bool> load() async {
    final jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );

    final Map<String, dynamic> jsonMap =
    json.decode(jsonString) as Map<String, dynamic>;

    _localizedStrings = jsonMap.map(
          (key, value) => MapEntry(key, value.toString()),
    );

    return true;
  }

  /// Returns the translated string for the given key.
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  /// Delegate used by Flutter to load localizations.
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}