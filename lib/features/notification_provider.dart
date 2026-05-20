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

  CityNotification? pop() {
    if (state.isEmpty) return null;
    final first = state.first;
    state = state.sublist(1);
    return first;
  }
}

final notificationQueueProvider =
    NotifierProvider<NotificationQueue, List<CityNotification>>(
  NotificationQueue.new,
);
