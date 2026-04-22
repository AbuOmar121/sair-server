import 'dart:math';

import 'package:sair_apis/src/domain/entities/app_notification.dart';
import 'package:sair_apis/src/persistence/app_backend.dart';

class NotificationService {
  static Future<AppNotification> create({
    required String userId,
    required String title,
    required String message,
    String? reportId,
  }) async {
    final backend = await AppBackend.instance();
    final notification = AppNotification(
      id: '${DateTime.now().microsecondsSinceEpoch}${Random().nextInt(99999)}',
      userId: userId,
      title: title,
      message: message,
      reportId: reportId,
      createdAt: DateTime.now(),
    );
    await backend.put('notifications', notification.id, notification.toJson());
    return notification;
  }

  static Future<List<AppNotification>> byUser(String userId) async {
    final backend = await AppBackend.instance();
    final notifications = (await backend.list('notifications'))
        .map(AppNotification.fromJson)
        .toList();
    return notifications.where((n) => n.userId == userId).toList();
  }
}
