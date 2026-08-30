import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _hasSeenOnboardingKey = 'hasSeenOnboarding';

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }
}