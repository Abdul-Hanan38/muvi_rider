// ignore_for_file: unintended_html_in_doc_comment

import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

double calculateDistance({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
  String unit = 'km',
}) {
  const double p = pi / 180; // More precise than 0.01745...
  const double earthRadiusKm = 6371;

  final a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;

  final distanceKm = 2 * earthRadiusKm * asin(sqrt(a)); // distance in km

  if (unit.toLowerCase() == 'mi') {
    return distanceKm * 0.621371; // convert km to miles
  } else {
    return distanceKm; // in km
  }
}

// launchUrl
openUrl(String url) async {
  if (await launchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

/// Recursive function to sanitize data before sending to Firebase Realtime Database.
/// Replaces NaN and Infinite values with 0.0 to prevent JSON serialization crashes on iOS.
/// Ensures that Maps are explicitly typed as Map<String, dynamic> for Firebase compatibility.
dynamic sanitizeFirebaseData(dynamic data) {
  if (data is num) {
    if (data.isNaN || data.isInfinite) {
      return 0.0;
    }
    return data;
  } else if (data is Map) {
    return data.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), sanitizeFirebaseData(value)));
  } else if (data is List) {
    return data.map((item) => sanitizeFirebaseData(item)).toList();
  }
  return data;
}
