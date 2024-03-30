// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `User Info`
  String get UserInfo {
    return Intl.message(
      'User Info',
      name: 'UserInfo',
      desc: '',
      args: [],
    );
  }

  /// `Input cookie`
  String get InputCookie {
    return Intl.message(
      'Input cookie',
      name: 'InputCookie',
      desc: '',
      args: [],
    );
  }

  /// `Input your cookie`
  String get InputCookieDialog_Title {
    return Intl.message(
      'Input your cookie',
      name: 'InputCookieDialog_Title',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get Login {
    return Intl.message(
      'Login',
      name: 'Login',
      desc: '',
      args: [],
    );
  }

  /// `Please select an output file`
  String get DownloadAudio_Hint {
    return Intl.message(
      'Please select an output file',
      name: 'DownloadAudio_Hint',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get LoginOut {
    return Intl.message(
      'Logout',
      name: 'LoginOut',
      desc: '',
      args: [],
    );
  }

  /// `Switch to`
  String get SwitchToAccount {
    return Intl.message(
      'Switch to',
      name: 'SwitchToAccount',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get Close {
    return Intl.message(
      'Close',
      name: 'Close',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get OK {
    return Intl.message(
      'OK',
      name: 'OK',
      desc: '',
      args: [],
    );
  }

  /// `Create a new song`
  String get NewSongDialogTitle {
    return Intl.message(
      'Create a new song',
      name: 'NewSongDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Custom mode`
  String get NewSongDialogCustomMode {
    return Intl.message(
      'Custom mode',
      name: 'NewSongDialogCustomMode',
      desc: '',
      args: [],
    );
  }

  /// `Enter lyrics`
  String get NewSongDialogLyricsHint {
    return Intl.message(
      'Enter lyrics',
      name: 'NewSongDialogLyricsHint',
      desc: '',
      args: [],
    );
  }

  /// `Generate random`
  String get NewSongDialogGenerateRandom {
    return Intl.message(
      'Generate random',
      name: 'NewSongDialogGenerateRandom',
      desc: '',
      args: [],
    );
  }

  /// `Style of music`
  String get NewSongDialogStyleOfMusic {
    return Intl.message(
      'Style of music',
      name: 'NewSongDialogStyleOfMusic',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get NewSongDialogMusicTitle {
    return Intl.message(
      'Title',
      name: 'NewSongDialogMusicTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter a prompt`
  String get NewSongDialogPromptHint {
    return Intl.message(
      'Enter a prompt',
      name: 'NewSongDialogPromptHint',
      desc: '',
      args: [],
    );
  }

  /// `make instrumental`
  String get NewSongDialogMakeInstrumental {
    return Intl.message(
      'make instrumental',
      name: 'NewSongDialogMakeInstrumental',
      desc: '',
      args: [],
    );
  }

  /// `Generate`
  String get Generate {
    return Intl.message(
      'Generate',
      name: 'Generate',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(
          languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
