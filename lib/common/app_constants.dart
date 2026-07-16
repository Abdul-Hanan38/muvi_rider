import 'dart:io';

import '../db/app_database.dart';
import '../features/language/domain/models/language_listing_model.dart';

class AppConstants {
  static const String title = 'muvi conductor';
  static const String baseUrl = 'https://app.muviglobal.com/';
  static String firbaseApiKey = (Platform.isAndroid)
      ? "android firebase api key"
      : "ios firebase api key";
  static String firebaseAppId =
      (Platform.isAndroid) ? "android firebase app id" : "ios firebase app id";
  static String firebasemessagingSenderId = (Platform.isAndroid)
      ? "android firebase sender id"
      : "ios firebase sender id";
  static String firebaseProjectId = (Platform.isAndroid)
      ? "android firebase project id"
      : "ios firebase project id";

  static String mapKey = (Platform.isAndroid)
      ? 'AIzaSyAiznBEzpPXCKW_hoQM9FMjA0k8j-al5Z8'
      : 'AIzaSyAiznBEzpPXCKW_hoQM9FMjA0k8j-al5Z8';

  static const String stripPublishKey = '';

  static List<LocaleLanguageList> languageList = [
    LocaleLanguageList(name: 'English', lang: 'en'),
    LocaleLanguageList(name: 'Arabic', lang: 'ar'),
    LocaleLanguageList(name: 'French', lang: 'fr'),
    LocaleLanguageList(name: 'Spanish', lang: 'es'),
    LocaleLanguageList(name: 'Albanian', lang: 'sq'),
    LocaleLanguageList(name: 'Azerbaijani', lang: 'az'),
    LocaleLanguageList(name: 'Portuguese', lang: 'pt'),
    LocaleLanguageList(name: 'Romanian', lang: 'ro'),
    LocaleLanguageList(name: 'Russian', lang: 'ru'),
    LocaleLanguageList(name: 'Swahili', lang: 'sw'),
    LocaleLanguageList(name: 'Thai', lang: 'th'),
    LocaleLanguageList(name: 'Turkish', lang: 'tr'),
    LocaleLanguageList(name: 'Bengali', lang: 'bn'),
    LocaleLanguageList(name: 'Urdu', lang: 'ur'),
    LocaleLanguageList(name: 'Vietnamese', lang: 'vi'),
    LocaleLanguageList(name: 'Chinese', lang: 'zh'),
    LocaleLanguageList(name: 'Dutch', lang: 'nl'),
    LocaleLanguageList(name: 'German', lang: 'de'),
    LocaleLanguageList(name: 'Hindi', lang: 'hi'),
    LocaleLanguageList(name: 'Indonesian', lang: 'id'),
    LocaleLanguageList(name: 'Italian', lang: 'it'),
    LocaleLanguageList(name: 'Korean', lang: 'ko'),
    LocaleLanguageList(name: 'Malay', lang: 'ms'),
    LocaleLanguageList(name: 'Japanese', lang: 'ja'),
    LocaleLanguageList(name: 'Polish', lang: 'pl'),
    LocaleLanguageList(name: 'Persian', lang: 'fa'),
    LocaleLanguageList(name: 'Amharic', lang: 'am'),
    LocaleLanguageList(name: 'Filipino', lang: 'fil'),
  ];
  static String packageName = '';
  static String signKey = '';
}

bool showBubbleIcon = false;
bool subscriptionSkip = false;
String choosenLanguage = 'en';
String mapType = '';
bool isAppMapChange = false;

AppDatabase db = AppDatabase();
