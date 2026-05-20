import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityNotification {
  const CityNotification({required this.message, this.isWarning = false});
  final String message;
  final bool isWarning;
}

class NotificationQueue extends Notifier<List<CityNotification>> {
  @override
  List<CityNotification> build() => const [];

  void push(CityNotification n) => state = [...state, n];

  List<CityNotification> drain() {
    final all = state;
    state = const [];
    return all;
  }
}

final notificationQueueProvider =
    NotifierProvider<NotificationQueue, List<CityNotification>>(
  NotificationQueue.new,
);
