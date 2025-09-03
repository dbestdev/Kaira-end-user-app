import '../constants/app_constants.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  final ApiService _apiService = ApiService();

  /// Get user's notifications with pagination and filtering
  Future<NotificationResponse> getNotifications({
    int page = 1,
    int limit = 20,
    NotificationStatus? status,
    NotificationType? type,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) {
        queryParams['status'] = status.value;
      }

      if (type != null) {
        queryParams['type'] = type.value;
      }

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/notifications',
      ).replace(queryParameters: queryParams);

      final data = await _apiService.get(uri.toString());
      return NotificationResponse.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Get notification statistics
  Future<NotificationStats> getNotificationStats() async {
    try {
      final data = await _apiService.get(
        '${AppConstants.baseUrl}/notifications/stats',
      );
      return NotificationStats.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching notification stats: $e');
    }
  }

  /// Get a specific notification
  Future<NotificationModel> getNotification(String notificationId) async {
    try {
      final data = await _apiService.get(
        '${AppConstants.baseUrl}/notifications/$notificationId',
      );
      return NotificationModel.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching notification: $e');
    }
  }

  /// Mark notification as read
  Future<NotificationModel> markAsRead(String notificationId) async {
    try {
      final data = await _apiService.put(
        '${AppConstants.baseUrl}/notifications/$notificationId/read',
        {},
      );
      return NotificationModel.fromJson(data);
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<Map<String, int>> markAllAsRead() async {
    try {
      final data = await _apiService.put(
        '${AppConstants.baseUrl}/notifications/mark-all-read',
        {},
      );
      return {'count': data['count'] ?? 0};
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  /// Archive a notification
  Future<NotificationModel> archiveNotification(String notificationId) async {
    try {
      final data = await _apiService.put(
        '${AppConstants.baseUrl}/notifications/$notificationId/archive',
        {},
      );
      return NotificationModel.fromJson(data);
    } catch (e) {
      throw Exception('Error archiving notification: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiService.delete(
        '${AppConstants.baseUrl}/notifications/$notificationId',
      );
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  /// Update notification status
  Future<NotificationModel> updateNotificationStatus(
    String notificationId,
    NotificationStatus status,
  ) async {
    try {
      final data = await _apiService.put(
        '${AppConstants.baseUrl}/notifications/$notificationId',
        {'status': status.value},
      );
      return NotificationModel.fromJson(data);
    } catch (e) {
      throw Exception('Error updating notification: $e');
    }
  }
}
