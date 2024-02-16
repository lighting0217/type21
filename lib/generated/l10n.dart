/// This file contains the generated code for localization using Flutter Intl IDE plugin.
/// It imports the necessary packages and defines the [S] class and [AppLocalizationDelegate] class.
/// The [S] class is responsible for loading the localized strings and providing them to the app.
/// The [AppLocalizationDelegate] class is responsible for loading the supported locales and initializing the [S] class.
library;

// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

class S {
  S._(); // Private constructor to prevent instantiation.

  static late S _instance;

  static S get instance {
    return _instance;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) async {
    final name = (locale.countryCode?.isEmpty ?? true)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    await initializeMessages(localeName);
    Intl.defaultLocale = localeName;
    _instance = S._();
    return _instance;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static S of(BuildContext context) {
    final instance = maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('th'),
  ];

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }
}
