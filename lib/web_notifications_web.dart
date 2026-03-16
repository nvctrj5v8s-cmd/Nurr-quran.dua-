import 'dart:html' as html;

class BrowserNotificationService {
  static bool get isSupported => html.Notification.supported;

  static Future<bool> requestPermission() async {
    if (!isSupported) {
      return false;
    }

    final current = html.Notification.permission;
    if (current == 'granted') {
      return true;
    }

    final result = await html.Notification.requestPermission();
    return result == 'granted';
  }

  static Future<void> show({
    required String title,
    required String body,
    String? icon,
  }) async {
    if (!isSupported) {
      return;
    }

    if (html.Notification.permission != 'granted') {
      return;
    }

    html.Notification(
      title,
      body: body,
      icon: icon,
    );
  }
}
