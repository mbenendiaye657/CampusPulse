import 'dart:async';
import 'package:dio/dio.dart';
import '../../core/services/auth_services.dart';

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api'));

  // StreamController pour broadcaster les notifs à tous les widgets qui écoutent
  final _controller = StreamController<List<NotificationItem>>.broadcast();
  Stream<List<NotificationItem>> get stream => _controller.stream;

  List<NotificationItem> _notifications = [];
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Timer? _timer;

  /// Démarre le polling toutes les 10 secondes
  void startPolling() {
    _fetchNotifications(); // appel immédiat
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchNotifications();
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetchNotifications() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final res = await _dio.get(
        '/notifications/',
        queryParameters: {'show_all': 'true'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List raw = res.data['notifications'] as List? ?? [];
      _notifications = raw
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();

      _controller.add(_notifications);
    } catch (_) {
      // Silencieux si pas de réseau
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final token = await AuthService.getToken();
      await _dio.post(
        '/notifications/$id/read/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // Mettre à jour localement sans attendre le prochain poll
      _notifications = _notifications
          .map((n) => n.id == id
              ? NotificationItem(
                  id: n.id,
                  title: n.title,
                  message: n.message,
                  isRead: true,
                  createdAt: n.createdAt)
              : n)
          .toList();
      _controller.add(_notifications);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      final token = await AuthService.getToken();
      await _dio.post(
        '/notifications/read-all/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      _notifications = _notifications
          .map((n) => NotificationItem(
              id: n.id,
              title: n.title,
              message: n.message,
              isRead: true,
              createdAt: n.createdAt))
          .toList();
      _controller.add(_notifications);
    } catch (_) {}
  }

  void dispose() {
    stopPolling();
    _controller.close();
  }
}
