class BrowserNotificationService {
  static bool get isSupported => false;

  static Future<bool> requestPermission() async {
    return false;
  }

  static Future<void> show({
    required String title,
    required String body,
    String? icon,
  }) async {}
}
